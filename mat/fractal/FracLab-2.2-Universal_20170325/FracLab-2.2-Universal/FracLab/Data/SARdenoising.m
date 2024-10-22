function slide=SARdenoising
% SAR denoising
%   
% Jacques LEVY-VEHEL, Pierrick LEGRAND
% Copyright 2002   
% Date: 2002/04/29  $

if nargout<1,
  playshow SARdenoising
else
  %========== Slide 1 ==========
slide(1).code={'im_sar=imread(''sar.tif'');'
    'imagesc(im_sar);colormap(gray);axis image;'};
  
slide(1).text={
['SAR images are generally difficult to read and to analyze because they '...
 'contain a large amount of a specific noise, called speckle. Dozens of '...
 'methods have been proposed to enhance their quality. Some use precise '...
 'knowledge about, e.g., the statistics of the noise, while other are '...
 'rather generic. The fractal denoising method is based on the following '...
 'simple observation : consider an image I, and its noisy version J. '...
 'Pick a particular location (x,y) at random in the image. Then, chances '...
 'are that the local regularity of I around (x,y) will be larger than '...
 'the one of J. Of course, this statement is rather imprecise if we do '...
 'not define how we measure regularity. We will however content '...
 'ourselves here with the intuitive fact that adding noise decreases the '...
 'local regularity at all points. ']};

%========== Slide 2 ==========

slide(2).code={
    'imagesc(im_sar);colormap(gray);axis image;'};


slide(2).text={
  
   ['Denoising can then be performed by '...
 'increasing in a controlled way the local regularity. This is exactly '...
 'how the fractal method works. '...
 'This image appears '...
 'very noisy, and does not seem to hold any useful information. However, '...
 'this is not quite true, as this scene does contain a river flowing '...
 'from North to South. Our aim here is to perform a pre-processing that '...
 'will enhance the image so that it will be possible to detect '...
 'automatically the river. Such a procedure is used by the IRD, a French '...
 'agency, which, in this particular application, is interested in '...
 'monitoring water resources in this region of Africa.']};

%========== Slide 3 ==========

% slide(3).code={'load den_sar;'
%     'imag=[im_sar den_im_sar0];'
%     'imagesc(imag);colormap(gray);%axis equal;'};

% slide(3).code={'load den_sar;'
%     '%imag=[im_sar den_im_sar0];'
%     'subplot(2,3,1);imagesc(im_sar);axis image;'
%     'subplot(2,3,2);imagesc(den_im_sar0);axis image;'
%     'colormap(gray);'};

slide(3).code={'load den_sar;'
    '%imag=[im_sar den_im_sar0];'
    '%subplot(2,3,1);%imagesc(im_sar);%axis image;'
    '%subplot(2,3,2);'
    'imagesc(den_im_sar0);axis image;'
    'colormap(gray);'};

slide(3).text={
   ['The river now appears, flowing from the top of the image ',...
  'and assuming roughly an inverted "Y" shape. Other values of the ',...
  'Spectrum shift value around 1.5 may give more visually pleasing ',...
  'results. ' ]};
%    ''};

%   %========== Slide 4 ==========
% 
% slide(4).code={
%    'load demo_phtL_lnikkei0'
%    'plot(phtL_lnikkei0);'
%    'AXIS([0 6000 0 7])' };
% 
% slide(4).text={
%    ['We will now estimate the local regularity of lnikkei: Click on 1D ', ...
%  'Exponents Estimation and choose Local H�lder Exponent then oscillation ', ...
%  'based method. In the window that appears, check that the Input data is ', ...
%  'lnikkei. Otherwise, select lnikkei by clicking on it in the Variables ', ...
%  'list of the main window, and hit Refresh in the Local H�lder Exponent ', ...
%  'window. Set the parameters as follows: Nmin = 1, Nmax = 8, ', ...
%  'Neighbourhood size = 16, and regression type = Least Square (see the ', ...
%  'help file corresponding to this menu for details on the meaning of ', ...
%  'these parameters). Hit Compute, and wait for less than a minute. The ', ...
%  'output signal appears in the Variables list of the main window, and is ', ...
%  'called pht_lnikkei0. View this signal, by pressing View in new in the ', ...
%  'View menu (check that pht_lnikkei0 is selected before doing so). As ', ...
%  'you see, most values of the local H�lder exponent are between 0 and 1, ', ...
%  'with a few peaks above 1 and up to more than 6. Recall that a H�lder ', ...
%  'exponent between 0 and 1 means that the signal is continuous but not ', ...
%  'differentiable at the considered point. In addition, the lower the ', ...
%  'exponent, the more irregular the signal. Looking at the original ', ...
%  'signal, it appears obvious that the log is almost nowhere smooth, ', ...
%  'which is consistent with the values of pht_lnikkei0. What is more ', ...
%  'interesting is that important events in the log have a specific ', ...
%  'signature in pht_lnikkei0: periods where "things happen" are ', ...
%  'characterized by sudden increase in regularity, which passes above 1, ', ...
%  'followed by very small values, e.g. below 0.2, which correspond to low ', ...
%  'regularity. Let us take some examples. The most prominent feature of ', ...
%  'pht_lnikkei0 is the peak at abscissa 2018 with amplitude larger than ', ...
%  '6. Note also that the points with the lowest values in regularity of ', ...
%  'the whole log are located just after this peak: The H�lder exponent is ', ...
%  'around 0.2 at abscissa roughly between 2020 and 2050, and 0.05 at ', ...
%  'abscissa between 2075 and 2100. Both values are well below the mean of ', ...
%  'pht_lnikkei0, which is 0.4 (its variance of is 0.036). As a matter of ', ...
%  'fact, only 10 percent of the points of the signal have an exponent ', ...
%  'smaller than 0.2.  Now the famous October 19 1987 krach corresponds to ', ...
%  'abscissa 2036, right in the middle on the first low regularity period ', ...
%  'after the peak. The days with smallest regularity in the whole log are ', ...
%  'thus logically located in the weeks following the krach, and one can ', ...
%  'assess precisely which days were more erratic. However, if you go back ', ...
%  'to original fnikkei225 signal, things are not so clear: although the ', ...
%  'krach is easily seen as a downward discontinuity at abscissa 2036, the ', ...
%  'area around this point does not appear to be more "special" than, for ', ...
%  'instance, the last part of the log (you may zoom on the different ', ...
%  'areas for easier visualization). ']};
% 
%   %========== Slide 5 ==========
% 
% slide(5).code={
%    '%subplot(3,2,1);'
%    'plot(phtL_lnikkei0);hold on;'
%    '%AXIS([2020 2050 0 0.3])' 
%    '%subplot(3,2,3);'
%    '%plot(phtL_lnikkei0);'
%    '%AXIS([2075 2100 0 0.3])'
%    'AXIS([2000 2150 0 1]);'
%    'plot(2036,phtL_lnikkei0(2036),''r*'');'
%    'hold off;'};
% slide(5).text={
%    ['The most prominent feature of ', ...
%  'pht_lnikkei0 is the peak at abscissa 2018 with amplitude larger than ', ...
%  '6. Note also that the points with the lowest values in regularity of ', ...
%  'the whole log are located just after this peak: The H�lder exponent is ', ...
%  'around 0.2 at abscissa roughly between 2020 and 2050, and 0.05 at ', ...
%  'abscissa between 2075 and 2100.',...
%  'Both values are well below the mean of ', ...
%  'pht_lnikkei0, which is 0.4 (its variance of is 0.036). As a matter of ', ...
%  'fact, only 10 percent of the points of the signal have an exponent ', ...
%  'smaller than 0.2.  Now the famous October 19 1987 krach corresponds to ', ...
%  'abscissa 2036, right in the middle on the first low regularity period ', ...
%  'after the peak. The days with smallest regularity in the whole log are ', ...
%  'thus logically located in the weeks following the krach, and one can ', ...
%  'assess precisely which days were more erratic. However, if you go back ', ...
%  'to original fnikkei225 signal, things are not so clear: although the ', ...
%  'krach is easily seen as a downward discontinuity at abscissa 2036, the ', ...
%  'area around this point does not appear to be more "special" than, for ', ...
%  'instance, the last part of the log (you may zoom on the different ', ...
%  'areas for easier visualization). ']};
% %========== Slide 6 ==========
% 
% slide(6).code={
%    'plot(phtL_lnikkei0);'
%    'AXIS([4450 4800 0 1.5])' };
% 
% slide(6).text={
%    ['Consider now another region which contains many points with low H�lder ', ...
%  'exponents with a few isolated very regular points (i.e. with exponent ', ...
%  'larger than 1). Look at the area between abscissa 4450 and 4800: This ', ...
%  'roughly corresponds to the "Asian crisis" period, which approximately ', ...
%  'took place between January 1997 and June 1998 (there are no exact ', ...
%  'dates for the beginning and end of the crisis. Some authors place the ', ...
%  'beginning of the crisis mid-1997, and the end by late 1999, or even ', ...
%  'later). On the graph of the original log of the Nikkei225, you can see ', ...
%  'that this period is quite erratic, with some discontinuities and ', ...
%  'pseudo-cycles (this behaviour arguably seems to extend between points ', ...
%  '3500 and maybe the end of the trace). Looking now at pht_lnikkei0, we ', ...
%  'notice that there are two peaks with exponents larger than one in the ', ...
%  'considered period (there is an additional such point around abscissa ', ...
%  '4300, which, however, is not followed by points with low values of ', ...
%  'regularity -e.g. smaller than 0.15-, but is preceded by such points, ', ...
%  'between abscissa 4255 and 4285). The first peak is around 4455, and is ', ...
%  'followed by irregular points between 4465 and 4475. The second is ', ...
%  'around 4730. This region, between abscissa 4450 and 4800, has a large ', ...
%  'proportion of irregular points: 12 percent of its points have exponent ', ...
%  'smaller than 0.15. This is three times the proportion observed in the ', ...
%  'whole log. In addition, this area is the one with highest density of ', ...
%  'points with exponent smaller than 0.15 (we exclude in these ', ...
%  'calculations the first and last points of the log, because of border ', ...
%  'effects).']};
% 
% %========== Slide 7 ==========


   


end
