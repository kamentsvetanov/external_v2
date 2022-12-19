function [EAStruct,modified_images] = EA_Image_Selection(EAStruct)
% bind good individuals to images

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

unbound_images = [2:1:7];
bound_images = [];
removed_positions = [];

%disp('---------------');

for i=1:1:length(EAStruct.Individuals)
	%disp(['BEFORE image selection: indiv ' num2str(i) ' : ' num2str(EAStruct.Individuals(i).bound_image_number) ', locked: ' num2str(EAStruct.Individuals(i).is_locked)]);
	if (EAStruct.Individuals(i).bound_image_number > 0)
		bound_images = [bound_images, EAStruct.Individuals(i).bound_image_number];
		removed_positions = [removed_positions, i];
		EAStruct.selected_individuals = [EAStruct.selected_individuals, i];
	end
end

[common_val,common_pos] = intersect(unbound_images,bound_images);
unbound_images(common_pos) = [];

modified_images = unbound_images;

if (isempty(unbound_images)) 
	%disp('No image selection.');
	return;
end

[Individual,Position] = EA_Select_Individual(EAStruct,length(unbound_images),'Image');

for i=1:1:length(unbound_images)
	%disp('----');
	%Position(i)
	
	mydata.images.image(unbound_images(i)).genotype = Individual(i).genotype;
	mydata.images.image(unbound_images(i)).evol_individualID = Position(i) ;
	EAStruct.Individuals(Position(i) ).bound_image_number = unbound_images(i); 
	%EAStruct.Individuals( Position(i) ).is_locked = 0;

	%[mydata.images.image(unbound_images(i)).evol_individualID ,	EAStruct.Individuals( Position(i) ).bound_image_number]
	

end
% 
% disp('----');
% for i=1:1:length(EAStruct.Individuals)
% 	disp(['AFTER image selection: indiv ' num2str(i) ' : ' num2str(EAStruct.Individuals(i).bound_image_number) ', locked: ' num2str(EAStruct.Individuals(i).is_locked)]);
% end