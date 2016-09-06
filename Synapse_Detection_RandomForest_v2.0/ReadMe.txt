READ ME
Please look at the B14 LAB, if you haven’t already.
Use generate_synapse_image to generate the true synaptic data for training.
Use generate_non_synapse_image to generate true non synaptic data for training.

Use sample_gen to create (8x8) (128x128px) data from one tif file for testing.

To use the linear detector - type init, make sure that all image for test/training are listed in the train.txt and text.txt all located in the reg_images file. The train also requires a 0/1 - ie synapse or no synapse.

once run use the -showimg to check the images have been loaded.
and selfeats to select image feature - this should already be done,
then extfeats
then train

This should be completed automatically.

Then run test to see the result - will be in a matrix q. (0/1)

Alexander