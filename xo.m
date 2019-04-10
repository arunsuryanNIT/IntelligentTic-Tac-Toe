function void=xo()
% This script runs an X-O game which is not easy to 
% beat although it operates on simple tricks of machine learning.Try beating
% the computer in the shortest time. Game time is indicated 
% after each game. The program randomly deceides who plays first.
% It is most convenient to "dock" the grid figure, so you don't
% have to keep looking for it after each turn.
%
% Use the keyboard's number pad (arranged in a square on the right 
% of the keyboard) to place your mark. The numbers 1 to 9 
% represent the 9 fields of the game's grid. For example:
%   - Entering 5 places an "O" in the center 
%   - Entering 7 places an "O" in the upper-left
%   - Entering 2 places an "O" in the bottom-middle
%
% By Arun Suryan,

clear all; clc; warning off 

%%%%% Create an empty grid
grid = ones(308,308)*0.98;
grid(100:104 , :) = 0;
grid(204:208 , :) = 0;
grid(: , 100:104) = 0;
grid(: , 204:208) = 0;
imshow(grid); colormap(jet);

%%%%% Define the image "X"
global X;
X = ones(99,99);
X(25:75, 48:52)=0.75;
X(48:52, 25:75)=0.75;
%imshow(X); % for debugging

%%%%% Define the image "O"
global O;
O = ones(99,99);
O(25:75, 23:27)=0.25;
O(23:27, 25:75)=0.25;
O(25:75, 73:77)=0.25;
O(73:77, 25:75)=0.25;
%imshow(O); % for debugging

%%%%% Create the status matrix (3X3) which will contain 0 
%%%%% in clear fields, 10 in "X" fields and 3 in "O" fields.
global status;
status = zeros(3,3);

%%%%% Define upper-left (ul) points of x/O locations in the grid matrix
ul_1=[1 1 1];
ul_2=[105 1 2];
ul_3=[209 1 3];
ul_4=[1 105 4];
ul_5=[105 105 5];
ul_6=[209 105 6];
ul_7=[1 209 7];
ul_8=[105 209 8];
ul_9=[209 209 9];

tic % start stop watch

%%%%% Let player go first 50% of the time
if rand > 0.5  
    % Player's turn
    temp = turn_player;
    grid = write_sign(O, eval(['ul_' num2str(temp)]) , grid);
    imshow(grid); colormap(jet);
end

%%%%% loop untill game ends
while 1  
    % Computer's turn
    temp = turn_pc;
    grid = write_sign(X, eval(['ul_' num2str(temp)]) , grid);
    imshow(grid); colormap(jet);
    %
    result = check4winner;
    if result ~=0 
        break
    end

    % Player's turn
    temp = turn_player;
    grid = write_sign(O, eval(['ul_' num2str(temp)]) , grid);
    imshow(grid); colormap(jet);
    %
    result = check4winner;
    if result~=0
        break
    end
end

%%%%% Show game time after game has ended 
disp(['***** Game Time = ' num2str(toc) ' seconds'])

%%%%% Sound effects, for game outcomes.
% Celebrate user's victory
if result==-1
    load handel
    sound(y,8192)
end
% Signal computer's victory
if result==1
    y=chirp(0:0.001:1,100,1,25,'q',[],'concave');
    sound(1000./y,8192); pause(0.3);sound(100./y,8192);
end
% Signal tied game
if result==2
    y=sin(0:500);
    sound(y,8192);pause(0.3);sound(y,8192);pause(0.3);
end

%%%%% Game over
% return warning state back to "on"
warning on
% dummy return for func xo
void = 0; 
% Want to play again?
if input('---> Enter "0" (zero) to play again: ') == 0;
    xo % play again
end

%%%%%% -----------------------------------------------------
%%%%%%   Function  "write_sign"
%%%%%% -----------------------------------------------------
function new_grid = write_sign(sign , location , grid)
% This functions updates the grid with the new played sign on it

global status;
global X ;
global O;

grid( location(1):location(1)+98 ,...
      location(2):location(2)+98 ) = sign;
new_grid = grid;
  
% Update the status matrix with the new played sign.
flag = 0;
if sign == X
    flag = 10;
elseif sign == O
    flag = 3;
end
status(location(3)) = flag;

%%%%%% -----------------------------------------------------
%%%%%% Function "turn_player"  
%%%%%% -----------------------------------------------------
function play = turn_player()
% Function to input from the user using the keypad

% Matrix used to translate number pad input into matrix index
translate = [3 2 1;6 5 4;9 8 7];

global status;

while 1  % Loop until a valid input is given
    req_loc = input('Clock is ticking, It''s your turn:  ');
    % "Requested Location" must be within range, and an integer.
    if  req_loc>0 & req_loc<10 & ceil(req_loc)==req_loc  
        if status(translate(req_loc))==0  %field must be free
            break % input was valid
        end
    end
    
    disp('*** Invalid Input');
end

% After obtaining a valid play, update the status matrix.
status(translate(req_loc)) = 3;
play = translate(req_loc);

%%%%%% -----------------------------------------------------
%%%%%%   function "check4winner"  
%%%%%% -----------------------------------------------------
function result = check4winner()
% Function to check if anybody won.

global status;

% Summing rows and columns and diagonals to check for wins
WinCol = sum(status);                   % 1X3 Matrix
WinRow = sum(status');                  % 1X3 Matrix
WinDiag1 = sum(diag(status));           % 1 element matrix
WinDiag2 = status(3)+status(5)+status(7);   % 1 element matrix

% no winner yet.. resume game
result = 0;

% Did X win?
if find(WinCol==30 | WinRow==30 | WinDiag1==30 | WinDiag2 ==30)
    disp(' ')
    disp('***** I beat you with the smarts of a 4-year-old ! *****')
    result = 1;
    return
end

% Did O win?
if find(WinCol==9 | WinRow==9 | WinDiag1==9 | WinDiag2 ==9)
    disp(' ')
    disp('***** Enjoy it while it lasts ! *****')
    result = -1;
    return
end

% If there are no winners, and no more clear fields. It's a tie.
if isempty(find(status==0))
    disp('***** Its a tie ! ****')
    result = 2;
end

%%%%%% -----------------------------------------------------
%%%%%%   Function turn_pc()  
%%%%%% -----------------------------------------------------
function play = turn_pc()
% Function to implement computer skill and have it play

global status;
play = 0;

%%%%% Win if you can
WinCol = find(sum(status) ==20 ); 
WinRow = find(sum(status')==20 );
WinDiag1 = find(sum(diag(status)) ==20); % 1 element matrix
WinDiag2 = find(status(3)+status(5)+status(7) ==20); % 1 element matrix
% Complete a two-in-a-row
if ~isempty(WinCol)
    %complete the column to win and return
    while 1
        % get a random number between 1 and 3 and adjust depending on
        % winning column number
        loc = ceil(3*rand)+(WinCol-1)*3;
        if status(loc)==0
            break % input was valid
        end
    end
    status(loc) = 10;
    play = loc;
    return
end
% Complete a two-in-a-column
if ~isempty(WinRow)
    %complete the row to win and return
    while 1
        % get a random number between 1,4,7 and adjust depending on 
        % winning row numner 
        loc = (3*ceil(3*rand)-2)+(WinRow-1)*1;
        if status(loc)==0
            break % input was valid
        end
    end
    status(loc) = 10;
    play = loc;
    return
end
% Complete a two-in-the-diagonal
if ~isempty(WinDiag1)
    %complete the first diagonal to win and return
    while 1
        % get a random number between 1,5 and 9.
        loc = 4*ceil(3*rand)-3;
        if status(loc)==0
            break % input was valid
        end
    end    
    status(loc) = 10;
    play = loc;
    return
end
% Complete a two-in-the-other-diagonal
if ~isempty(WinDiag2)
    %complete the second diagonal to win and return
    while 1
        % get a random number between 3,5 and 7.
        loc = 2*ceil(3*rand)+1;
        if status(loc)==0
            break % input was valid
        end
    end      
    status(loc) = 10;
    play = loc;
    return
end

%%%%%  Block a player's two-in-a-row
BlockCol = find(sum(status) ==6 ); 
BlockRow = find(sum(status')==6 ); 
BlockDiag1 = find(sum(diag(status)) ==6); % 1 element matrix
BlockDiag2 = find(status(3)+status(5)+status(7) ==6); % 1 element matrix
% Block a two-in-a-row
if ~isempty(BlockRow)
    %complete the row to block player
    while 1
        % get a random number between 1,4,7 and adjust depending on 
        % winning row numner 
        loc = (3*ceil(3*rand)-2)+(BlockRow-1)*1;
        if status(loc)==0
            break % input was valid
        end

    end

    status(loc) = 10;
    play = loc;
    return
end
% Block a two-in-a-column
if ~isempty(BlockCol)
    %complete the column to block player
    while 1
        % get a random number between 1 and 3 and adjust depending on
        % winning column number
        loc = ceil(3*rand)+(BlockCol-1)*3;
        if status(loc)==0
            break % input was valid
        end

    end
    status(loc) = 10;
    play = loc;
    return
end
% Block a two-in-the-diagonal
if ~isempty(BlockDiag1)
    %complete the first diagonal to block player
    while 1
        % get a random number between 1,5 and 9.
        loc = 4*ceil(3*rand)-3;
        if status(loc)==0
            break % input was valid
        end
    end    
    status(loc) = 10;
    play = loc;
    return
end
% Block a two-in-the-other-diagonal
if ~isempty(BlockDiag2)
    %complete the second diagonal to block player
    while 1
        % get a random number between 3,5 and 7.
        loc = 2*ceil(3*rand)+1;
        if status(loc)==0
            break % input was valid
        end
    end      
    status(loc) = 10;
    play = loc;
    return
end

%%%%% take the middle field if it's available 
%%%%% after the second round, 40% of the time.
if status(5) == 0 && ~isempty(find(status==3)) && rand>0.4
    play = 5;
    status(5) = 10;
    return
end

%%%%%  Play randomly, when all the above does not apply
while play==0
    % get a random number between 1 and 9
    loc = ceil(9*rand);
    if status(loc)==0
        play = loc;  % input was valid
        break
    end

end
status(loc) = 10;
return


%%%%%% -----------------------------------------------------
%%%%%% Experimental Code Below 
%%%%%% -----------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% use this code as a fall back instead of "turn_pc" above 
%%% (computer plays randomly)
%%%
% function play = turn_pc()
% global status;
% while 1
%     % get a random number between 1 and 9
%     req_loc = ceil(9*rand);
%     if status(req_loc)==0
%         break % input was valid
%     end
% end
% status(req_loc) = 1;
% play = req_loc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% use this code as a fall back (2 player game)
%%%
% function play = turn_pc()
%%%%% Translate number pad input into matrix index
% translate = [3 2 1;6 5 4;9 8 7];
% global status;
% while 1
%     req_loc = input('--- Plyer one (X):  ');
%     if req_loc>0 & req_loc<10
%         if status(translate(req_loc))==0
%             break % input was valid
%         end
%     end
%     disp('*** Invalid Input');
% end
% status(translate(req_loc)) = 1;
% play = translate(req_loc);
