function [MRS_struct] = GannetLoad(temppfile, waterfile)
%function [MRS_struct] = MRSLoadPfiles110825(temppfile, waterfile)
%function [MRS_struct] = MRSLoadPfiles110825(pfiles, FreqPhaseAlign)
% CJE110825.  Loads P files for analysis
%
%inputs:
% pfiles     = cell array of P filenames { 'pfile1.7' 'pfile2.7' ... }
% FreqPhaseAlign  = Perform frame-by-frame frequency and phase alignment of spectra and
% Reject pairs of frames based if phase or freq > 3*stdev
%              0=NO, 1=YES


% 091201: Dec 09.  Initial version, based on Richard's code
% 100301: March 10.
%         Phasing of water data - use first point for each average
%          independently to reduce phase errors.
%         Return a struct, rather than set of arrays
% 101001: Oct 2010, named MRSdatacheck - based on MRSLoadPfiles 100301
%         Frequency realign each transient (water peak) - store as
%          DiffFIDrealign.  Note waterspec, gabaspec, and sumspec
%          are the unaligned versions
%         Generate plots for frequecy shifts, phase variation
%         Fix timeseries swap bug
% 101101: Phase correct each transient first point in FID
% 6 Nov 2010: ###########problem with water fitting############
% 110208: Renamed as MRSLoadPfiles110208
%         Save realigned data by default to gabaspec etc...
% 110303: Make frame-by-frame frequency and phase correction
%          optional - MRS data AND water scans
%         OutlierReject.
% 110310: Fit Creatine resonance for each pair of shots (Wadell,2007)
%           for frequency and phase correction
% 110426: Return Cr fit info for internal reference
% 110825: Modify code to load Philips and Siemens data (Richards
%           visit Aug 2011)


%TO DO:
% Get subject ID, series name, voxel x,y,z from pfile header
% Voigt fit for Creatine to get Cr amplitude as an internal reference
%  ! may need to initialise this fit with the sum lorentzian fit


%110825 - dont user varargin , don't need waterfname for GE
% need to update the freq align in this version to 1107

%global freq;
%global filename;
global Comft0;
global Comft1;
global ComftW;
%global pfile;

%LB=4; %RE default
%LB = 1.3;
LB = 3; %RE 120228 more reasonable than 1.3...
ZeroFillTo = 32768;

%ZeroFillTo = 16384;

MRS_struct.pfile=temppfile;
if(nargin > 1)
    MRS_struct.waterfile = waterfile;
    MRS_struct.Reference_compound='H2O';
else
    MRS_struct.Reference_compound='Cr';
end
MRS_struct.LB=LB;
MRS_struct.versionload = '120222a';
FreqPhaseAlign=1; %110825



global_rescale = 1/1e17;  % rescale all loaded data to get a sensible range

if iscell(temppfile) == 1 % it's a cell array, so work out the number of elements
    numpfiles=numel(temppfile);
    pfiles=temppfile;
else
    numpfiles=1;  % it's just one pfile
    pfiles{1}=temppfile;
end


% 110825 work out which vendor GE *.7 Philips SDAT or Siemens RDA
lastchar=pfiles{1};
lastchar=lastchar((end-1):end);

if(strcmpi(lastchar,'.7'))
    MRS_struct.vendor = 'GE';
    MRS_struct.Reference_compound='H2O';
elseif(strcmpi(lastchar,'AT'))
    MRS_struct.vendor = 'Philips';
    if(strcmp(lastchar,'AT'))
       MRS_struct.spar_string='SPAR';
    else
        MRS_struct.spar_string='spar';
    end
elseif(strcmpi(lastchar,'TA'))
    MRS_struct.vendor = 'Philips_data';
elseif(strcmpi(lastchar,'DA'))
    MRS_struct.vendor = 'Siemens';
else
    error('Unrecognised filetype: should end .7 .SDAT or .RDA')
end


% create dir for output
if(exist('./MRSload_output','dir') ~= 7)
    mkdir MRSload_output
end

if(strcmpi(MRS_struct.vendor,'Siemens'))
    numpfiles = numpfiles/2;
end
for ii=1:numpfiles
        MRS_struct.pfile{ii};
    %LB=2;
    split = 1;
    i = sqrt(-1);
    %  MRS_struct.phase(ii,:)=0;
    %disp('opening p-file %s', MRS_struct.pfile{ii})
    % Open Pfile to read reference scan data.
    
    % 110825
        if(strcmpi(MRS_struct.vendor,'Siemens'))
                    %Need to set Water_Positive based on water signal
            %This is a start, but is not yet there...
            if(exist('waterfile'))    
                MRS_struct.Reference_compound='H2O';
                MRS_struct = SiemensRead_RE(MRS_struct, temppfile{ii*2-1},temppfile{ii*2}, waterfile{ii});
            else
                 MRS_struct.Reference_compound='Cr';
                MRS_struct = SiemensRead_RE(MRS_struct, temppfile{ii*2-1},temppfile{ii*2});
            end
                da_xres = MRS_struct.npoints;
            da_yres = 1;
            totalframes = 1;
            FullData = MRS_struct.data.';
            if(strcmp(MRS_struct.Reference_compound,'H2O'))
            WaterData = MRS_struct.data_water;
            end
            LarmorFreq = MRS_struct.LarmorFreq;
            % work out frequency scale 110825
            Csize=ZeroFillTo;
            %Csize=size(AllFramesFT,1);
            freqrange=MRS_struct.sw/MRS_struct.LarmorFreq;
            MRS_struct.freq=(Csize+1-(1:1:Csize))/Csize*freqrange+4.7-freqrange/2.0;
            MRS_struct.FreqPhaseAlign=0;
        elseif(strcmpi(MRS_struct.vendor,'Philips'))
            %Need to set Water_Positive based on water signal
            Water_Positive=1;
            MRS_struct.ii=ii;
            if strcmpi(MRS_struct.Reference_compound,'H2O')
                MRS_struct = PhilipsRead(MRS_struct, temppfile{ii}, waterfile{ii});
                WaterData = MRS_struct.data_water;
            else
                MRS_struct = PhilipsRead(MRS_struct, temppfile{ii});
            end
            da_xres = MRS_struct.npoints;
            da_yres = MRS_struct.nrows;
            totalframes = MRS_struct.nrows;
            FullData = MRS_struct.data;


            LarmorFreq = 127.8;
         elseif(strcmpi(MRS_struct.vendor,'Philips_data'))
            Water_Positive=0;
            MRS_struct.ii=ii;
            temppfile{ii};
            MRS_struct = PhilipsRead_data(MRS_struct, temppfile{ii});
            da_xres = MRS_struct.npoints;
            da_yres = MRS_struct.nrows*MRS_struct.Navg(ii);
            totalframes = MRS_struct.nrows*MRS_struct.Navg(ii);
            FullData = MRS_struct.data;
            LarmorFreq = 127.8;       

        elseif(strcmpi(MRS_struct.vendor,'GE'))
            LarmorFreq = 127.35;
            Water_Positive=1;
            fid = fopen(pfiles{ii},'r', 'ieee-be');

            if fid == -1
                tmp = [ 'Unable to locate Pfile ' pfiles{ii} ];
                disp(tmp);
                return;
            end
            % return error message if unable to read file type.


            % Determine size of Pfile header based on Rev number
            status = fseek(fid, 0, 'bof');
            [f_hdr_value, count] = fread(fid, 1, 'real*4');
            rdbm_rev_num = f_hdr_value(1);
            if( rdbm_rev_num == 7.0 );
                pfile_header_size = 39984;  % LX
            elseif ( rdbm_rev_num == 8.0 );
                pfile_header_size = 60464;  % Cardiac / MGD
            elseif (( rdbm_rev_num > 5.0 ) && (rdbm_rev_num < 6.0));
                pfile_header_size = 39940;  % Signa 5.5
            else
                % In 11.0 and later the header and data are stored as little-endian
                fclose(fid);
                fid = fopen(pfiles{ii},'r', 'ieee-le');
                status = fseek(fid, 0, 'bof');
                [f_hdr_value, count] = fread(fid, 1, 'real*4');
                if (f_hdr_value == 9.0)  % 11.0 product release
                    pfile_header_size= 61464;
                elseif (f_hdr_value == 11.0);  % 12.0 product release
                    pfile_header_size= 66072;
                elseif (f_hdr_value > 11.0) & (f_hdr_value < 100.0)  % 14.0 and later
                    status = fseek(fid, 1468, 'bof');
                    pfile_header_size = fread(fid,1,'integer*4');
                else
                    err_msg = sprintf('Invalid Pfile header revision: %f', f_hdr_value );
                    return;
                end
            end

            % Read header information
            status = fseek(fid, 0, 'bof');
            [hdr_value, count] = fread(fid, 102, 'integer*2');
            npasses = hdr_value(33);
            nslices = hdr_value(35);
            nechoes = hdr_value(36);
            nframes = hdr_value(38);
            point_size = hdr_value(42);
            da_xres = hdr_value(52);
            da_yres = hdr_value(53);
            rc_xres = hdr_value(54);
            rc_yres = hdr_value(55);
            start_recv = hdr_value(101);
            stop_recv = hdr_value(102);
            nreceivers = (stop_recv - start_recv) + 1;


            % Specto Prescan pfiles
            if (da_xres == 1) & (da_yres == 1)
                da_xres = 2048;
            end
            %Not declared for GE previously
            MRS_struct.npoints=da_xres;

            % Determine number of slices in this Pfile:  this does not work for all cases.
            slices_in_pass = nslices/npasses;

            % Compute size (in bytes) of each frame, echo and slice
            data_elements = da_xres*2;
            frame_size = data_elements*point_size;
            echo_size = frame_size*da_yres;
            slice_size = echo_size*nechoes;
            mslice_size = slice_size*slices_in_pass;
            my_slice = 1;
            my_echo = 1;
            my_frame = 1;

            FullData=zeros(nreceivers, da_xres , da_yres-my_frame+1);
            %ChannelSplit=zeros(nreceivers, da_xres,split);

            %Start to read data into Eightchannel structure.
            totalframes=da_yres-my_frame+1;
            chunk=uint16(totalframes/split);

            data_elements2 = data_elements*totalframes*nreceivers;

            %  % Compute offset in bytes to start of frame.
            file_offset = pfile_header_size + ((my_frame-1)*frame_size);

            status = fseek(fid, file_offset, 'bof');

            % read data: point_size = 2 means 16 bit data, point_size = 4 means EDR )
            if (point_size == 2 )
                [raw_data, count] = fread(fid, data_elements2, 'integer*2');
            else
                [raw_data, count] = fread(fid, data_elements2, 'integer*4');
            end

            fclose(fid);

            % get some info from the header
            % pfil_hdr = [pfiles{ii} '.hdr' ]

            % fid = fopen(pfil_hdr,'r');

            % if fid == -1
            %   % no header, so try to run print_raw_headers
            %   stat=system('which print_raw_headers') % see if print_raw_headers is available
            %   if(stat)
            %     tmp = [ 'print_raw_headers ' pfiles{ii}
            %     system(
            % end


            % 110303 CJE
            % calculate Navg from nframes, 8 water frames, 2 phase cycles
            % Needs to be specific to single experiment - for frame rejection
            MRS_struct.Navg(ii) = (nframes-8)*2;
            MRS_struct.Nwateravg = 8; %moved from MRSGABAinstunits RE 110726
            MRS_struct.TR = 1.8;
            ShapeData = reshape(raw_data,[2 da_xres totalframes nreceivers]);
            ZeroData = ShapeData(:,:,1,:);
            WaterData = ShapeData(:,:,2:9,:);
            FullData = ShapeData(:,:,10:end,:);

            totalframes = totalframes-9;

            Frames_for_Water = 8;

            FullData = FullData.*repmat([1;i],[1 da_xres totalframes nreceivers]);
            WaterData = WaterData.*repmat([1;i],[1 da_xres Frames_for_Water nreceivers]);

            FullData = squeeze(sum(FullData,1));
            FullData = permute(FullData,[3 1 2]);


            WaterData = squeeze(sum(WaterData,1));
            WaterData = permute(WaterData,[3 1 2]);
            % at this point, FullData(rx_channel, point, average)

            firstpoint=conj(WaterData(:,1,:));
            firstpoint=repmat(firstpoint, [1 da_xres 1]);
            % here firstpoint(rx_channel,[], average)


            % CJE March 10 - correct phase of each Water avg independently
            WaterData=WaterData.*firstpoint*global_rescale;

            %Multiply the Eightchannel data by the firstpointvector
            % zeroth order phasing of spectra
            % CJE Nov 09: do global rescaling here too
            % don't really need the phasing step here if performing frame-by-frame phasing
            for receiverloop = 1:nreceivers
                FullData(receiverloop,:) = FullData(receiverloop,:)*firstpoint(receiverloop,1,1)*global_rescale;
                % WaterData(receiverloop,:) = WaterData(receiverloop,:)*firstpoint(receiverloop,1,1)*global_rescale;
            end

            % sum over Rx channels
            FullData = squeeze(sum(FullData,1));
            WaterData = squeeze(sum(WaterData,1));
            MRS_struct.waterdata=WaterData;
            MRS_struct.sw = 5000;  %should really pick this up from the header
            %%%%%% end of GE specific load

        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End of initial Load segment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    MRS_struct.zf=ZeroFillTo/MRS_struct.npoints;
    
        %110825
    %time=(1:1:size(FullData,1))/2000;
    time=(1:1:size(FullData,1))/MRS_struct.sw;
    time_zeropad=(1:1:ZeroFillTo)/(MRS_struct.sw);
    DataSize = size(FullData,2);
    
    %raee 111109 Philips data for mona does not have water spectra...
    if(strcmpi(MRS_struct.Reference_compound,'H2O'))
        %figure(14)
        %plot(real(fftshift(fft(WaterData))));
        % Finish processing water data.
        if(strcmpi(MRS_struct.vendor,'GE'))
            ComWater = sum(WaterData,2);
        elseif(strcmpi(MRS_struct.vendor,'Siemens'))
            ComWater = WaterData;
        else
            ComWater = WaterData.';
        end
        ComWater = ComWater.*exp(-(time')*LB*pi);
        % 110825
        %MRS_struct.waterspec(ii,:)=fftshift(fft(ComWater,size(ComWater,1)*8,1))';
        MRS_struct.waterspec(ii,:)=fftshift(fft(ComWater,ZeroFillTo,1))';
    end
    
    %Water = WaterData;
    

    %RE 110726  This section will not apply to the Siemens data
    if(strcmpi(MRS_struct.vendor,'Siemens') ~= 1)
        % CJE Oct 10
        % FT each transient (Zerofill 8 times)
        %AllFramesFT=fftshift(fft(FullData,ZeroFillTo,1),1);
        % FT each transient (Zerofill 8 times)
        % 110715 - do line broadening here, rather than after freq correction
        MRS_struct.gabadata=FullData;
        FullData = FullData.* repmat( (exp(-(time')*LB*pi)), [1 totalframes]);
        AllFramesFT=fftshift(fft(FullData,ZeroFillTo,1),1);
        
        % work out frequency scale 110825
        Csize=ZeroFillTo;
        %Csize=size(AllFramesFT,1);
        freqrange=MRS_struct.sw/LarmorFreq;
        MRS_struct.freq=(Csize+1-(1:1:Csize))/Csize*freqrange+4.7-freqrange/2.0;
        
        %%%%%%%%%  Frame-by-frame Frequency Realignment to spectrum (assumed water) maximum%%%%%%%%
        % find peak location for frequency realignment
        [FrameMax, FrameMaxPos] = max(AllFramesFT, [], 1);
        % align all peaks to _first_ transient (should be closest value set during Prescan)
        FrameShift = FrameMaxPos - FrameMaxPos(1);
        
        
        if(strcmpi(MRS_struct.vendor,'Philips_data'))     
           for jj=1:totalframes
         	 AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -FrameShift(jj));
           end
        elseif (strcmpi(MRS_struct.vendor,'Philips'))
            for jj=1:totalframes
         	 AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -FrameShift(jj));
           end
        end
        
        MRS_struct.waterfreq(ii,:) = MRS_struct.freq(FrameMaxPos);
        
        % CJE Oct10: Calculate sum and difference spectra - no filtering at this point...
        %     OddFramesFTrealign=AllFramesFT(:,1:2:end);
        %     EvenFramesFTrealign=AllFramesFT(:,2:2:end);
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
            AllFramesFTrealign=reshape(AllFramesFTrealign,[size(AllFramesFTrealign,1) MRS_struct.Navg(ii) MRS_struct.nrows]);
            AllFramesFT=reshape(AllFramesFT,[size(AllFramesFT,1) MRS_struct.Navg(ii) MRS_struct.nrows]);
            OddFramesFTrealign=AllFramesFTrealign(:,:,1:2:end);
            EvenFramesFTrealign=AllFramesFTrealign(:,:,2:2:end);
            OddFramesFT=AllFramesFT(:,:,1:2:end);
            EvenFramesFT=AllFramesFT(:,:,2:2:end);
            OddFramesFTrealign=reshape(OddFramesFTrealign,[size(OddFramesFTrealign,1) size(OddFramesFTrealign,2)*size(OddFramesFTrealign,3) ]);
            EvenFramesFTrealign=reshape(EvenFramesFTrealign,[size(EvenFramesFTrealign,1) size(EvenFramesFTrealign,2)*size(EvenFramesFTrealign,3) ]);
            OddFramesFT=reshape(OddFramesFT,[size(OddFramesFT,1) size(OddFramesFT,2)*size(OddFramesFT,3) ]);
            EvenFramesFT=reshape(EvenFramesFT,[size(EvenFramesFT,1) size(EvenFramesFT,2)*size(EvenFramesFT,3) ]);
            numreject=0;
        else
            OddFramesFT=AllFramesFT(:,1:2:end);
            EvenFramesFT=AllFramesFT(:,2:2:end);
        end
        
        
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
            %Creatine align is an issue... if we align all spectra to
            %creatine, we introduce a subtraction error.  If we try to
            %apply the pairwise approach used for GE, this fails as Philips
            %data acquired in phase cycle blocks of 16.
            
            %Still need ranges for Creatine align plot
            z=abs(MRS_struct.freq-3.12);
            lb=find(min(z)==z);
            z=abs(MRS_struct.freq-2.72);
            ub=find(min(z)==z);
            MRS_struct.fwhmHz(ii)=1/0;
            
            %For now just align Cr of the sum to 3.03 ppm...
            freqrange = MRS_struct.freq(lb:ub);
            Cr_initx = [ 30 0.1 3.0 0 0 0 ];
            CrSumSpec = sum(AllFramesFT(lb:ub,:),2);
            CrSumSpecFit = FitPeaksByFrames(freqrange, CrSumSpec, Cr_initx);
            CrFreqShift = CrSumSpecFit(3);
            CrFreqShift = CrFreqShift - 3.03*LarmorFreq;
            CrFreqShift = CrFreqShift ./ (3*42.58*(MRS_struct.freq(2) - MRS_struct.freq(1) ));
            CrFreqShift_points = round(CrFreqShift);
            size(AllFramesFT);
            for jj=1:(size(AllFramesFT,2)*size(AllFramesFT,3))
                AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -CrFreqShift_points);
            end
            for jj=1:(size(AllFramesFT,2)*size(AllFramesFT,3)/2)
                EvenFramesFTrealign(:,jj)=circshift(EvenFramesFT(:,jj), -CrFreqShift_points);
                OddFramesFTrealign(:,jj)=circshift(OddFramesFT(:,jj), -CrFreqShift_points);
            end
            
            AllFramesFTrealign=AllFramesFTrealign*exp(1i*pi/180*CrSumSpecFit(4));
                OddFramesFTrealign=OddFramesFTrealign*exp(1i*pi/180*CrSumSpecFit(4));
                EvenFramesFTrealign=EvenFramesFTrealign*exp(1i*pi/180*CrSumSpecFit(4));
                
        else
            % Do Creatine sum fit in all cases
            %110825  Need tosearch for pm values rather than simply use indices
            %since SW and npoints may change...
            z=abs(MRS_struct.freq-3.12);
            lb=find(min(z)==z);
            z=abs(MRS_struct.freq-2.72);
            ub=find(min(z)==z);
            %lb = 17651; ub=18000;

            MRS_struct.freq(17651);
            MRS_struct.freq(18000);
            freqrange = MRS_struct.freq(lb:ub);
            %figure(9);plot( real(AllFramesFT(:,1:2)));
            % initx = [area hwhm f0 phase baseline0 baseline1 ]
            % n.b. initials are in [ area ppm ppm rads baseline0 baseline1 ], but returned values are
            % [area FWHM_Hz Hz deg baseline0 baseline1]
            Cr_initx = [ 30 0.1 3.0 0 0 0 ];

            %Come up with better initial conditions by fitting to the Cr sum
            %For Philipps data, initial hase may be way off - need to fix
            %phase before fixing anything else
            CrSumSpec = sum(AllFramesFT(:,:),2);
            if(strcmpi(MRS_struct.vendor,'Philips'))
                %Assume frequency is roughly right - filter just the Cr/Cho
                %part and look for maximum...apply phase to data.
                
                Phase_test_data=sum(MRS_struct.data,2);
                Phase_test_data=WaterFilter(Phase_test_data,50,MRS_struct.sw);
                Phase_test_data=fftshift(fft(Phase_test_data-FatFilter(Phase_test_data,120,MRS_struct.sw,220),ZeroFillTo));
%                 size(Phase_test_data)
%                 plot(real(Phase_test_data))
%                 stop here
%                 z2=abs(MRS_struct.freq-3.12);
%                 lb2=find(min(z2)==z2)
%                 z2=abs(MRS_struct.freq-2.92);
%                 ub2=find(min(z2)==z2)
%                 range=lb2:ub2;
%                 range_middle=size(range,2)/2.0;
%                 %find max in spectrum in that range
%                 [number index]=max(real(CrSumSpec(range)));
%                 range=range+round(index-range_middle);
%                 CrSumSpec=ifft(fftshift(CrSumSpec));
%                 CrSumSpec = WaterFilter(CrSumSpec,50,MRS_struct.sw);
%                 CrSumSpec = FatFilter(CrSumSpec,50,MRS_struct.sw);
%                 CrSumSpec=fftshift(fft(CrSumSpec));
%                 figure(12)
                range=1:ZeroFillTo;
                [CrSumSpec phase] = FixCrPhase(Phase_test_data,range);
            else
                phase=0;
            end
            phase;
            %CrSumSpec = CrSumSpec(lb:ub);
            CrSumSpec = sum(AllFramesFT(lb:ub,:),2)*exp(1i*pi/180*(phase));
            %plot(MRS_struct.freq(lb:ub),real(CrSumSpec));
            CrSumSpecFit = FitPeaksByFrames(freqrange, CrSumSpec, Cr_initx);
            %Apply phase to AllFrameFT
            CrSumSpecFit(4);
            AllFramesFT=AllFramesFT*exp(1i*pi/180*(CrSumSpecFit(4)+phase));
%             figure(12);
%             plot(MRS_struct.freq,real(sum(AllFramesFT,2)));
%             %size(CrSumSpec)
%             %plot(MRS_struct.freq,real(CrSumSpec'));
            Cr_initx = CrSumSpecFit;
            %rescale to account for Navg
            Cr_initx(1) = Cr_initx(1)/size(AllFramesFT,2);
            Cr_initx(5) = 0;
            %       Cr_initx(6) = 0;

            MRS_struct.Cr_area(ii) = Cr_initx(1);
            MRS_struct.Cr_freq(ii) = Cr_initx(3);
            MRS_struct.fwhmHz(ii) = Cr_initx(2);
             
            % 110310 Freq and Phase alignment by Cr fitting
            if(FreqPhaseAlign)

                %need to rescale area for 1 frame bit messy -
                % convert back to  ppm, rads for new initialiser
                % CJE 120118 - correct linear baseline too. without this
                % the linear component can dominate
                conv = [1 1/(2*42.576*3) 1/(42.576*3) (pi/180) 1 1/size(AllFramesFT,2) ];

                Cr_initx = Cr_initx .* conv;

                % Water peak freq shift estimation
                % find peak location for frequency realignment
                if Water_Positive ==1
                    [FrameMax, FrameMaxPos] = max(AllFramesFT, [], 1);
                else
                    [FrameMax, FrameMaxPos] = min(AllFramesFT, [], 1);
                end
                % align all peaks to _first_ transient (should be closest value set during Prescan)
                FrameShift = FrameMaxPos - FrameMaxPos(1);

                % 110715. only fit the OFF frames
                %Cr_frames = AllFramesFT(lb:ub,:);
                Cr_frames_OFF = AllFramesFT(lb:ub,2:2:end);

                % 110715 - only fit OFF frames
                [CrFitParams, rejectframes] = FitPeaksByFrames(freqrange, Cr_frames_OFF, Cr_initx);
                %    [CrFitParams, rejectframes] = FitPeaksByFrames(freqrange, AllFramesFT(lb:ub,:), Cr_initx);
                CrFreqShift = CrFitParams(:,3);
                CrFreqShift = CrFreqShift - 3.03*LarmorFreq;
                CrFreqShift = CrFreqShift ./ (3*42.58*(MRS_struct.freq(2) - MRS_struct.freq(1) ));
                CrFreqShift_points = round(CrFreqShift);

                % average over ON and OFF spectra - otherwise there is a net freq shift of ON relative to
                %  Off, causing a subtraction error 110310 CJE
                %CrFreqShift_avg = reshape(CrFreqShift, [2 (numel(CrFreqShift)/2) ]);
                %CrFreqShift_avg = mean(CrFreqShift_avg, 1);
                %CrFreqShift_avg = repmat(CrFreqShift_avg, [2 1]);
                %CrFreqShift_avg = round(reshape(CrFreqShift_avg, [ (numel(CrFreqShift_avg)) 1 ]));
                %CrPhaseShift = CrFitParams(:,4);
                %110715 CJE
                % ON spectra are much more variable in baseline - use only OFFs for
                % freq and phase correction
                size(CrFreqShift);
                CrFreqShift_avg = repmat(CrFreqShift', [2 1]);
                CrFreqShift_avg = round(reshape(CrFreqShift_avg, [ (numel(CrFreqShift_avg)) 1 ]));
                %figure(5); plot(CrFreqShift_avg','o-');
                CrPhaseShift = CrFitParams(:,4);
                MRS_struct.phase(ii)= mean(CrPhaseShift);
                CrPhaseShift = repmat(CrPhaseShift, [2 1 ]);
                CrPhaseShift = reshape(CrPhaseShift, [ (numel(CrPhaseShift)) 1 ]);
                size(CrFreqShift_avg);

                for jj=1:totalframes
                    AllFramesFTrealign(:,jj)=AllFramesFT(:,jj) * exp(1i * -CrPhaseShift(jj) * pi /180);
                    AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -CrFreqShift_avg(jj)); %Cr peak realignment
                    %	 AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -CrFreqShift_points(jj)); %Cr peak realignment
                    %	 AllFramesFTrealign(:,jj)=circshift(AllFramesFT(:,jj), -FrameShift(jj)); %Water peak realignment
                end

                % Need to recalculate these from the f, phase corrected versions...
                OddFramesFTrealign=AllFramesFTrealign(:,1:2:end);
                EvenFramesFTrealign=AllFramesFTrealign(:,2:2:end);

                % CJE 110303: OutlierReject
                % reject based on water fit (not Cr)
                %	 frequpper = mean(MRS_struct.waterfreq(ii,:)) + 3*std(MRS_struct.waterfreq(ii,:));
                %	 freqlower = mean(MRS_struct.waterfreq(ii,:)) - 3*std(MRS_struct.waterfreq(ii,:));
                %	 size(MRS_struct.waterfreq(ii,:))
                %	 frequpper = repmat(frequpper, [1 totalframes]);
                %	 freqlower = repmat(freqlower, [1 totalframes]);

                % CJE branch on 120126, merge with master 120209
                % Add condition to discard points after jump in
                % water freq > 0.01ppm
                %RAEE - make this GE specific for now... both because short
                %phase cycle and because WS is 'bad'...
                if(strcmpi(MRS_struct.vendor,'GE'))
                    waterreject = [ 0 (abs(diff(MRS_struct.waterfreq(ii,:)))>0.01) ]
                    %waterreject checks ALL frames
                    waterreject = reshape(waterreject, [2 numel(waterreject)/2])
                    waterreject = max(waterreject);

                    rejectframes = rejectframes + waterreject';
                end
                %prevent double counting
                rejectframes = (rejectframes>0);

                lastreject = -1;
                numreject=0;
                %    for jj=1:totalframes
                %      if rejectframes(jj)
                % work out the ON_OFF pair to reject
                % set to zero - will come out in the wash after SUM, DIFF
                %	pairnumber = round(jj/2);
                %	if(pairnumber ~= lastreject) %trap condition where ON and OFF in a pair are rejected
                %	  OddFramesFTrealign(1:end, pairnumber) = 0;
                %	  EvenFramesFTrealign(1:end, pairnumber) = 0;
                %	       AllFramesFTrealign(1:end, (2*pairnumber-1):(2*pairnumber)) = 0;
                %	  lastreject = pairnumber;
                %	  numreject = numreject + 2;
                %	end
                %      end
                %    end

                % 110715 New reject - only fit OFF (second frame in 'pair')
                for pairnumber=1:(totalframes/2)
                    if rejectframes(pairnumber)
                        OddFramesFTrealign(1:end, pairnumber) = 0;
                        EvenFramesFTrealign(1:end, pairnumber) = 0;
                        AllFramesFTrealign(:,(2*pairnumber)) =  EvenFramesFTrealign(1:end, pairnumber);
                    end
                end
                if(strcmpi(MRS_struct.vendor,'GE'))
                  numreject = 2 * 2 * sum(rejectframes); % ON and OFF get rejected and TWO phase cycles.
                else
                  numreject = 2 * sum(rejectframes); % ON and OFF get rejected.
                end 
                %not keen on this phase cycles=2 hard code. Added GE IF

                for jj=1:(totalframes/2)
                    AllFramesFTrealign(:,(2*jj-1)) = OddFramesFTrealign(1:end, jj);
                end
                if(strcmpi(MRS_struct.vendor,'Philips_data'))
                    MRS_struct.Navg(ii) = MRS_struct.Navg(ii)*MRS_struct.nrows - numreject*MRS_struct.nrows; %need to check up on both Philips RE 121214
                elseif(strcmpi(MRS_struct.vendor,'Philips'))
                    MRS_struct.Navg(ii) = MRS_struct.Navg(ii) - numreject*MRS_struct.Navg(ii)/MRS_struct.nrows; %need to check up on both Philips RE 121214
                else
                    MRS_struct.Navg(ii) = MRS_struct.Navg(ii) - numreject;
                end
            else
                % no realignment
                AllFramesFTrealign=AllFramesFT;
                OddFramesFTrealign=AllFramesFT(:,1:2:end);
                EvenFramesFTrealign=AllFramesFT(:,2:2:end);
                numreject = -1;
            end
        end
        DiffSpecRealign(ii,:)=sum(OddFramesFTrealign,2)-sum(EvenFramesFTrealign,2);
        SumSpecRealign(ii,:)=sum(OddFramesFTrealign,2)+sum(EvenFramesFTrealign,2);
        MRS_struct.OFFspec(ii,:)=sum(EvenFramesFTrealign,2);
        % Do the line broadening on the realigned data
        %DiffFIDrealign=ifft(fftshift(DiffSpecRealign(ii,:)));
        %SumFIDrealign=ifft(fftshift(SumSpecRealign(ii,:)));
        %[B,A] = butter(4, 0.02, 'high');
        %DiffFIDrealign = filtfilt(B,A,DiffFIDrealign);
        %SumFIDrealign = filtfilt(B,A,SumFIDrealign);
        %110715: line broadening of all frames at the start - for Cr fit
        %DiffFIDrealign = DiffFIDrealign.*exp(-(time_zeropad)*LB*pi); %has already been zeropadded..
        %SumFIDrealign = SumFIDrealign.*exp(-(time_zeropad)*LB*pi);
        %DiffSpecRealign(ii,:)=fftshift(fft(DiffFIDrealign));
        %SumSpecRealign(ii,:)=fftshift(fft(SumFIDrealign));
        
        % ditto on non-aligned data (CJE 30/10/11)
        DiffSpec(ii,:)=sum(OddFramesFT,2)-sum(EvenFramesFT,2);
        SumSpec(ii,:)=sum(OddFramesFT,2)+sum(EvenFramesFT,2);
        %DiffFID=ifft(fftshift(DiffSpec(ii,:)));
        %SumFID=ifft(fftshift(SumSpec(ii,:)));
        %110715: line broadening of all frames at the start - for Cr fit
        %DiffFID = DiffFID.*exp(-(time_zeropad)*LB*pi); %has already been zeropadded..
        %SumFID = SumFID.*exp(-(time_zeropad)*LB*pi);
        %DiffSpec(ii,:)=fftshift(fft(DiffFID));
        %SumSpec(ii,:)=fftshift(fft(SumFID));
        
        %  CJE Feb 11:  Return the realigned spectra
        MRS_struct.gabanoalign(ii,:)=DiffSpec(ii,:);
        MRS_struct.gabaspec(ii,:)=DiffSpecRealign(ii,:);
        MRS_struct.sumspec(ii,:)=SumSpecRealign(ii,:);
        % calculate FWHM, based on NAA peak
        %MRS_struct.fwhmHz(ii)=-fwhm(MRS_struct.freq(18300:18850), ...
        %			      real(MRS_struct.sumspec(ii,18300:18850)))*42.58*3;
        %     MRS_struct.PhaseStdevDeg(ii) = std(framephase);
        MRS_struct.FreqStdevHz(ii) = std(MRS_struct.waterfreq(ii,:))* ...
            42.58*3;
        MRS_struct.phase(ii) = 0; % initial zeroth order phase
        MRS_struct.phase_firstorder(ii) = 0; % initial 1st order phase
        MRS_struct.FreqPhaseAlign = FreqPhaseAlign; %frame-by-frame f align
        MRS_struct.EvenFrames = EvenFramesFTrealign;
        MRS_struct.Rejects(ii) = numreject;
        
        if(ishandle(101))
            close(101)
        end
        h=figure(101);
        figTitle = ['GannetLoad Output'];
        set(gcf,'Name',figTitle,'Tag',figTitle, 'NumberTitle','off');
        
        subplot(2,2,1)
        MRSplotprepostalign(MRS_struct,ii)
        title('Edited Spectrum');
        %figure(53)
        subplot(2,2,2)
        if(FreqPhaseAlign)
                        if(strcmpi(MRS_struct.vendor,'Philips_data'))
                % 110825 - don't worry about this, for the moment
                plot([1:DataSize], MRS_struct.waterfreq(ii,:)');
            else
                rejectframesAll = [rejectframes'; rejectframes'];
                rejectframesAll = reshape(rejectframesAll, [1 numel(rejectframesAll) ]);
                rejectframesplot = (1./rejectframesAll) .*  MRS_struct.waterfreq(ii,:);
                plot([1:DataSize], MRS_struct.waterfreq(ii,:)', '-', [1:DataSize], rejectframesplot, 'ro');
            end
        else
            plot([1:DataSize], MRS_struct.waterfreq(ii,:)');
        end
        xlabel('frame'); ylabel('\omega_0')
        title('Water Frequency, ppm');
        
        subplot(2,2,3)
        if(FreqPhaseAlign)
            %    plotrealign=[ real(AllFramesFT((lb+50):(ub-150),:)) ;
            %		  real(AllFramesFTrealign((lb+50):(ub-150),:)) ];
            plotrealign=[ real(AllFramesFT((lb):(ub),:)) ;
                real(AllFramesFTrealign((lb):(ub),:)) ];
            imagesc(plotrealign);
            title('Cr Frequency, pre and post align');
        else
            tmp = 'No realignment';
            text(0,0.9, tmp, 'FontName', 'Courier');
        end
        
        subplot(2,2,4);
        axis off;
        
        tmp = [ 'filename    : ' MRS_struct.pfile{ii} ];
        tmp = regexprep(tmp, '_','-');
        text(0,0.9, tmp, 'FontName', 'Courier');
        tmp = [ 'Navg        : ' num2str(MRS_struct.Navg(ii)) ];
        text(0,0.8, tmp, 'FontName', 'Courier');
        tmp = sprintf('FWHM (Hz)   : %.2f', MRS_struct.fwhmHz(ii) );
        text(0,0.7, tmp, 'FontName', 'Courier');
        tmp = sprintf('FreqSTD (Hz): %.2f', MRS_struct.FreqStdevHz(ii));
        text(0,0.6, tmp, 'FontName', 'Courier');
        tmp = [ 'LB (Hz)     : ' num2str(MRS_struct.LB,2) ];
        text(0,0.5, tmp, 'FontName', 'Courier');
        %tmp = [ 'Align/Reject: ' num2str(MRS_struct.FreqPhaseAlign) ];
        %text(0,0.5, tmp, 'FontName', 'Courier');
        tmp = [ 'Rejects     : '  num2str(MRS_struct.Rejects(ii)) ];
        text(0,0.4, tmp, 'FontName', 'Courier');
        tmp = [ 'LoadVer     : ' MRS_struct.versionload ];
        text(0,0.3, tmp, 'FontName', 'Courier');
        
        script_path=which('GannetLoad');
        % CJE update for GE
        Gannet_circle=[script_path(1:(end-12)) 'GANNET_circle.png'];
        Gannet_circle_white=[script_path(1:(end-12)) 'GANNET_circle_white.jpg'];
        A=imread(Gannet_circle);
        A2=imread(Gannet_circle_white);
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A);axis off; axis square;
        
        
        
        pfil_nopath = MRS_struct.pfile{ii};
        %for philips .data
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
        fullpath = MRS_struct.pfile{ii};
        fullpath = regexprep(fullpath, '\./', '');      
        fullpath = regexprep(fullpath, '/', '_');
        end
        %  pfil_nopath = pfil_nopath( (length(pfil_nopath)-15) : (length(pfil_nopath)-9) );
        tmp = strfind(pfil_nopath,'/');
        tmp2 = strfind(pfil_nopath,'\');
        if(tmp)
            lastslash=tmp(end);
        elseif (tmp2)
            %maybe it's Windows...
            lastslash=tmp2(end);
        else
            % it's in the current dir...
            lastslash=0;
        end
         
         if(strcmpi(MRS_struct.vendor,'Philips'))
             tmp = strfind(pfil_nopath, '.sdat');
             tmp1= strfind(pfil_nopath, '.SDAT');
             if size(tmp,1)>size(tmp1,1)
                 dot7 = tmp(end); % just in case there's another .sdat somewhere else...
             else
                 dot7 = tmp1(end); % just in case there's another .sdat somewhere else...
             end
         elseif(strcmpi(MRS_struct.vendor,'GE'))
            tmp = strfind(pfil_nopath, '.7');
            dot7 = tmp(end); % just in case there's another .7 somewhere else...
            elseif(strcmpi(MRS_struct.vendor,'Philips_data'))
            tmp = strfind(pfil_nopath, '.data');
            dot7 = tmp(end); % just in case there's another .data somewhere else...
        elseif(strcmpi(MRS_struct.vendor,'Siemens'))
            tmp = strfind(pfil_nopath, '.rda');
            dot7 = tmp(end); % just in case there's another .rda somewhere else...
        end
        pfil_nopath = pfil_nopath( (lastslash+1) : (dot7-1) );
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A2);axis off; axis square;
        % fix pdf output, where default is cm
        set(gcf, 'PaperUnits', 'inches');
        set(gcf,'PaperSize',[8.5 6.5]);
        set(gcf,'PaperPosition',[.25 .25 8 6]);
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
            pdfname=[ 'MRSload_output/' fullpath '.pdf' ];
        else
            pdfname=[ 'MRSload_output/' pfil_nopath  '.pdf' ];
        end
        saveas(h, pdfname);
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A);axis off; axis square;
    else
        %This bit is the Siemens clean-up - since only one on and one off
        %are brought in, no alignment is necessary.  Not sure what else has
        %not yet been done...
        %Prob need to fit the Cr peak to pull out amplitude?
        %20120123  Need to apply line broadening here
        MRS_struct.gabadata=FullData;
        ONData = MRS_struct.ondata.'.* repmat( (exp(-(time')*LB*pi)), [1 1]);
        OFFData = MRS_struct.offdata.'.* repmat( (exp(-(time')*LB*pi)), [1 1]);
        %End of 20120123 LB change
        %Looks like it didn't go far enough!
%         MRS_struct.gabaspec(ii,:) = fftshift(fft(MRS_struct.ondata-MRS_struct.offdata,ZeroFillTo));
%         MRS_struct.sumspec(ii,:) = fftshift(fft(MRS_struct.ondata+MRS_struct.offdata,ZeroFillTo));
%         MRS_struct.OFFspec(ii,:) = fftshift(fft(MRS_struct.offdata,ZeroFillTo));
        MRS_struct.gabaspec(ii,:) = fftshift(fft(ONData-OFFData,ZeroFillTo));
        MRS_struct.sumspec(ii,:) = fftshift(fft(ONData+OFFData,ZeroFillTo));
        MRS_struct.OFFspec(ii,:) = fftshift(fft(OFFData,ZeroFillTo));
%Still worth outputting the figure...
        if(ishandle(101))
            close(101)
        end
        h=figure(101);
        figTitle = ['GannetLoad Output'];
        set(gcf,'Name',figTitle,'Tag',figTitle, 'NumberTitle','off');
        subplot(2,2,1)
        MRSplotnoalign(MRS_struct,ii)
        title('Edited Spectrum');
        %figure(53)
        subplot(2,2,3)
        tmp = 'No realignment';
        text(0,0.9, tmp, 'FontName', 'Courier');  
        axis off;
        subplot(2,2,4);
        axis off;
        tmp = [ 'filename    : ' MRS_struct.pfile{ii*2} ];
        tmp = regexprep(tmp, '_','-');
        text(0,0.9, tmp, 'FontName', 'Courier');
        %tmp = [ 'Navg        : ' num2str(MRS_struct.Navg) ];
        %text(0,0.8, tmp, 'FontName', 'Courier');
        %tmp = sprintf('FWHM (Hz)   : %.2f', MRS_struct.fwhmHz(ii) );
        %text(0,0.7, tmp, 'FontName', 'Courier');
        %tmp = sprintf('FreqSTD (Hz): %.2f', MRS_struct.FreqStdevHz(ii));
        %text(0,0.6, tmp, 'FontName', 'Courier');
        tmp = [ 'LB (Hz)     : ' num2str(MRS_struct.LB,2) ];
        text(0,0.5, tmp, 'FontName', 'Courier');
        %tmp = [ 'Align/Reject: ' num2str(MRS_struct.FreqPhaseAlign) ];
        %text(0,0.5, tmp, 'FontName', 'Courier');
        %tmp = [ 'Rejects     : '  num2str(MRS_struct.Rejects(ii)) ];
        %text(0,0.4, tmp, 'FontName', 'Courier');
        tmp = [ 'LoadVer     : ' MRS_struct.versionload ];
        text(0,0.3, tmp, 'FontName', 'Courier');
        
        script_path=which('GannetLoad');
        Gannet_circle=[script_path(1:(end-12)) 'GANNET_circle.png'];
        Gannet_circle_white=[script_path(1:(end-12)) 'GANNET_circle_white.jpg'];
        A=imread(Gannet_circle);
        A2=imread(Gannet_circle_white);
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A);axis off; axis square;
        
        
        
        pfil_nopath = MRS_struct.pfile{ii};
        %for philips .data
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
        fullpath = MRS_struct.pfile{ii};
        fullpath = regexprep(fullpath, '\./', '');      
        fullpath = regexprep(fullpath, '/', '_');
        end
        %  pfil_nopath = pfil_nopath( (length(pfil_nopath)-15) : (length(pfil_nopath)-9) );
        tmp = strfind(pfil_nopath,'/');
        tmp2 = strfind(pfil_nopath,'\');
        if(tmp)
            lastslash=tmp(end);
        elseif (tmp2)
            %maybe it's Windows...
            lastslash=tmp2(end);
        else
            % it's in the current dir...
            lastslash=0;
        end
         
         if(strcmpi(MRS_struct.vendor,'Philips'))
             tmp = strfind(pfil_nopath, '.sdat');
             tmp1= strfind(pfil_nopath, '.SDAT');
             if size(tmp,1)>size(tmp1,1)
                 dot7 = tmp(end); % just in case there's another .sdat somewhere else...
             else
                 dot7 = tmp1(end); % just in case there's another .sdat somewhere else...
             end
         elseif(strcmpi(MRS_struct.vendor,'GE'))
            tmp = strfind(pfil_nopath, '.7');
            dot7 = tmp(end); % just in case there's another .7 somewhere else...
            elseif(strcmpi(MRS_struct.vendor,'Philips_data'))
            tmp = strfind(pfil_nopath, '.data');
            dot7 = tmp(end); % just in case there's another .data somewhere else...
        elseif(strcmpi(MRS_struct.vendor,'Siemens'))
            tmp = strfind(pfil_nopath, '.rda');
            dot7 = tmp(end); % just in case there's another .rda somewhere else...
        end
        pfil_nopath = pfil_nopath( (lastslash+1) : (dot7-1) );
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A2);axis off; axis square;
        % fix pdf output, where default is cm
        set(gcf, 'PaperUnits', 'inches');
        set(gcf,'PaperSize',[8.5 6.5]);
        set(gcf,'PaperPosition',[.25 .25 8 6]);
        if(strcmpi(MRS_struct.vendor,'Philips_data'))
            pdfname=[ 'MRSload_output/' fullpath '.pdf' ];
        else
            pdfname=[ 'MRSload_output/' pfil_nopath  '.pdf' ];
        end
        saveas(h, pdfname);
        hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
        %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
        image(A);axis off; axis square;
    end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% end of main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % 110310 CJE fit sum pairs to get freq and phase information of frames
    % 111111 RAEE FitPeaksByFrames moved to separate file - used also in
    % GannetFit if the Reference_compound  is Cr.
    
    
    
