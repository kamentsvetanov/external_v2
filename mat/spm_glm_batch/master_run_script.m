% Model spec, estimate, results

run('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts/prep_model1.m')
run('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts/prep_model2.m')
run('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts/prep_model3.m')
run('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts/prep_model4.m')

%% Design review  - done in prep script as well

addpath('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts');
publish_model('model1', 1, 0);
publish_model('model2', 1, 0);
publish_model('model3', 1, 0);
publish_model('model4', 1, 0);

%% Publish robust reg - done in prep script as well

addpath('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/scripts');
publish_model('model1', 0, 1);
publish_model('model2', 0, 1);
publish_model('model3', 0, 1);
publish_model('model4', 0, 1);
