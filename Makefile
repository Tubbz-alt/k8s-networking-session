suspend-all:
	cd ./vagrant-boxes/single-node-single-cont;\
	vagrant suspend;\
	cd ../single-node-multi-cont;\
	vagrant suspend;\
	cd ../multi-node-l2;\
	vagrant suspend;\
	cd ../multi-node-overlay;\
	vagrant suspend;\

setup-all:
	cd ./vagrant-boxes/single-node-single-cont;\
	vagrant up;\
	cd ../single-node-multi-cont;\
	vagrant up;\
	cd ../multi-node-l2;\
	vagrant up;\
	cd ../multi-node-overlay;\
	vagrant up;\

destroy-all:
	cd ./vagrant-boxes/single-node-single-cont;\
	vagrant destroy -f;\
	cd ../single-node-multi-cont;\
	vagrant destroy -f;\
	cd ../multi-node-l2;\
	vagrant destroy -f;\
	cd ../multi-node-overlay;\
	vagrant destroy -f;\

setup-snsc:
	cd ./vagrant-boxes/single-node-single-cont;\
	vagrant up;\
	vagrant ssh;
setup-snmc:
	cd ./vagrant-boxes/single-node-multi-cont;\
	vagrant up;\
	vagrant ssh;
setup-mnl2:
	cd ./vagrant-boxes/multi-node-l2;\
	vagrant up;
setup-mnol:
	cd ./vagrant-boxes/multi-node-overlay;\
	vagrant up;
	
	