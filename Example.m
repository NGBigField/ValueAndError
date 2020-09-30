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


%% Using standart-deviation:
% We've measured something N times. All measurements are of the same value, and not of a known changing process. 
% Thus all measurements can be thought of as a random process who's mean is an estimatio of the real value, and the error
% is the standart deviation:
N = 100; % Numnrt of measurements:
sigma = 3;
mean  = 42;

measurements = mean + sigma*randn(N,1);

X = ValueAndError.fromstandardDeviationOfValues( measurements );






