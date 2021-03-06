%{
    This is a small guide to explain about the different ways of using ValueAndError.
    Each block contains explanation and executable code examples.
    Press ctrl+enter to execute the whole code-block.
%}
%%
clearvars; close all; clc;

% Create ValueAndError using the Standard Constructor:
m = ValueAndError( 17.3 , 0.2 ) ; % The mass of the object is 17.3 [kg] up to an error of 0.2 [kg]
disp("m");
disp(m);

% Create ValueAndError using the Standard Constructor for a vector of measurements all having the same error:
a = ValueAndError( [2.46 , 2.98 , 3.03 , 2.54]  , 0.01) ; % The Acceleration was measured 4 times 
                                                          % with values [2.46 , 2.98 , 3.03 , 2.54] [m/(s^2)] all with an error of 0.01 [m/(s^2)]
disp("a");                                                          
disp(a);

% Create ValueAndError using a function that combines the two previous ValuesAndErro's:
SigmaF = ValueAndError.fromFunction( @(m,a) m*a , m , a ); % SigmaF=m*a
disp("SigmaF");
disp(SigmaF);

% Take the Avarage of the calculated values as the estimatation of the force:
MeanSigmaF = SigmaF.mean();
disp("MeanSigmaF");
disp(MeanSigmaF);

%% Using the mass to calculate its relativistic resting mass:

% When the speed of light almost certein: Using ValueAndError, You can use either a function-handle, or a symbolic-function:
c = ValueAndError( 299792458 , 5  );
% Using a function-handle:
E_1 = ValueAndError.fromFunction( @(m,c) m*c^2 , m , c );
% Using a symbolic-function:
syms E_( m_ , c_ )
E_( m_ , c_ ) = m_*c_^2;
E_2 = ValueAndError.fromFunction( E_ , m , c );

% When the speed of light is a constant: The cleaner way is to use a symbolic-function, but both are shown below:
% One way, is to use one of the previous methods above, but with Error=0:
c = ValueAndError( 299792458 , 0  );
% Using a function-handle:
E_3 = ValueAndError.fromFunction( @(m,c) m*c^2 , m , c );
% Using a symbolic-function:
syms E_( m_ , c_ )
E_( m_ , c_ ) = m_*c_^2;
E_4 = ValueAndError.fromFunction( E_ , m , c );
% The second way, is to define a function where C is a constant:
c = 299792458;
% Using a function-handle:
E_5 = ValueAndError.fromFunction( @(m) m*(299792458^2) , m );
% Using a symbolic-function:
syms E_(m_)
E_(m_) = m_*c^2;
E_6 = ValueAndError.fromFunction( E_ , m );



disp("E");
disp(E_1);
disp(E_2);
disp(E_3);
disp(E_4);
disp(E_5);
disp(E_6);


%% Using standart-deviation to create ValueAndError:
% We've measured something N times. All measurements are of the same value, and not of a known changing process. 
% Thus all measurements can be thought of as a random process who's mean is an estimatio of the real value, and the error
% is the standart deviation:
N = 100; % Numnrt of measurements:
Sigma = 3;
Mean  = 42;

measurements = Mean + Sigma*randn(N,1);

X = ValueAndError.fromstandardDeviationOfValues( measurements );
disp(X)

%% Working with ValueAndError:
% arramge the values of X:
sortedValues = sort( X.Value );
xError       = mean(X.Error); % not very sceintifical, but helps to make a point
% Create a sorted X object:
x_sroted = ValueAndError(sortedValues , xError)

% Take some members of X from the beggining and from rge end and append them together:
x_last   = x_sroted(92 : 4 : end )
x_first  = x_sroted( 1 : 4 : 8   )
x_append = x_first.append(x_last)


%% deriving ValueAndError from many ValueAndErrors:
% This is going to take some time... be patient.
Y = ValueAndError.fromFunction(   @(x,xMean,m,F)  ( (F^(3/2)) / sqrt(m) )*sind(x-xMean)    , x_append , x_append.mean , m , MeanSigmaF )
% note to use the same order of function inputs when calling ValueAndError.fromFunction()

% compare to normal function  (no derived errors nvolved): 
y   =  ( ( (MeanSigmaF.Value)^(3/2) ) / sqrt(m.Value) )*sind(x_append.Value - x_append.mean.Value );
ComputationError = rms(Y.Value-y)

xFit = linspace(30,55,1000);
yFit = ( ( (MeanSigmaF.Value)^(3/2) ) / sqrt(m.Value) )*sind( xFit       - mean(xFit)   );

% plot results:
%errorbar(x,y,yneg,ypos,xneg,xpos)
FigH = figure();
ErrorH = errorbar(x_append.Value , Y.Value , Y.Error , Y.Error , x_append.Error , x_append.Error); 
ErrorH.LineStyle = 'none';
ErrorH.DisplayName = "Measurements";
hold on
plotH  = plot(xFit , yFit);
plotH.LineStyle = ':';
plotH.DisplayName ="Fit" ;
xlabel("X [m]" , 'Interpreter','latex' , 'FontSize',16)
ylabel("$$ Y =  \frac{ F^{ \frac{3}{2} } }{ \sqrt{m} } sin(X- \bar X)   $$" ,'Interpreter','latex' , 'FontSize',16)
title("ValueAndError"+newline+"The best way to compute scientific errors"  , 'Interpreter','latex');
LegH = legend();
LegH.Location = 'best';
grid on
grid minor