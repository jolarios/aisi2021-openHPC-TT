# Trabajo Tutelado - OpenHPC
## Administración de Infrastructuras y Sistemas Informáticos, Curso 20-21
En este trabajo simularemos un entorno HPC mediante Vagrant y VBox creando un clúster con OpenHPC. Dentro del repositorio se encuentran los archivos necesarios para la creación del nodo máster (*sms*) configurado para soportar dos nodos de cómputo (*c1* y *c2*). 

### Arquitectura:
![arquitectura](https://github.com/jolarios/aisi2021-openHPC-TT/raw/main/img/arquitectura.png)

### Pasos a seguir para la creación del clúster:

1. Clonar este repositorio: ```git clone https://github.com/jolarios/aisi2021-openHPC-TT```
2. Una vez clonado ejecutar ```vagrant up --provision```
3. Instalar el Extension Pack de VBox (para el soporte del *chipset* **PIIX3**).
4. Crear dos nuevas máquinas en VBox de tipo **Linux Red-Hat de 64 bits** con:
    - Mínimo **25GB de disco duro** y **2GB de RAM**
    - Configurar el *boot menu* y establecer como primera opción el **arranque por red**
    ![vbox2](https://github.com/jolarios/aisi2021-openHPC-TT/raw/main/img/vbox2.png)
    - Habilitar únicamente el adaptador de red 1 de *c1* y *c2* como "*Red interna*" con nombre *management* y configurar las MACs de cada máquina:
    ![vbox3](https://github.com/jolarios/aisi2021-openHPC-TT/raw/main/img/vbox3.png)
        - C1: 080027CB726A
        - C2: 0800276A567B
5. Una vez realizados los pasos anteriores, cuando haya acabado Vagrant y la máquina *sms* esté *online* podremos ejecutar las dos máquinas que hemos creado. La imagen del SO será proporcionada por **Warewulf** por lo que habrá que seleccionar **Cancelar** en la ventana que encontramos debajo.
![img](https://github.com/jolarios/aisi2021-openHPC-TT/raw/main/img/vbox4.png)

6. En cuanto los nodos *c1* y *c2* se hayan iniciado podremos hacer los últimos ajustes para conseguir un clúster HPC funcional con Slurm. Será necesaria la ejecución de los siguientes comandos, que ejecutan finalmente un ejemplo de ejecución interactiva:
    ```shell
    # Copy /etc/hosts personalized for each node 
	scp /vagrant/provisioning/hosts_c1 root@c1:/etc/hosts
	scp /vagrant/provisioning/hosts_c2 root@c2:/etc/hosts
	
	# Adding user test
	useradd -m test
	# File synchronization
	wwsh file resync passwd shadow group
	
	# slurmd process starting and status check on both nodes
	pdsh -w c[1-2] systemctl start slurmd
	pdsh -w c[1-2] systemctl status slurmd
	
	# c1 and c2 nodes from DOWN to idle state and info show
	scontrol update nodename=c[1-2] state=idle
	sinfo
	
	# Switch to "test" user
	su - test
	# Loading modules mpicc & prun
	module load gnu8
	module load prun
	module load openmpi3
	
	# Compile MPI "hello world" example
	mpicc -O3 /opt/ohpc/pub/examples/mpi/hello.c
	# Submit interactive job request and use prun to launch executable
	srun -n 2 -N 2 --pty /bin/bash
	prun ./a.out
    ```

