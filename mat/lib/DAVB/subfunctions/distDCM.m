function [d,err] = distDCM(ind)
% computes error type for DCM model comparison

switch ind
    case 1
        d = 0;
        err = 0;
    case 2
        d = 1;
        err = 1;
    case 3
        d = 1;
        err = 1;
    case 4
        d = 2;
        err = 1;
    case 5
        d = 1;
        err = 2;
    case 6
        d = 1;
        err = 2;
    case 7
        d = 2;
        err = 2;
    case 8
        d = 4;
        err = 3;
    case 9
        d = 5;
        err = 3;
    case 10
        d = 3;
        err = 3;
    case 11
        d = 4;
        err = 3;
end
        