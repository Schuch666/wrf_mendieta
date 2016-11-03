# Instalación y ejecución de WRF en Mendieta #

## Indice

1. Introducción 
2. Descarga de WRF/WPS/ARWpost   
3. Instalación de WRF + dependencias
4. Obtención de datos terrestres
5. Ejecución del modelo
6. Bibliografía & Guías de instalación tomadas de referencia

_______________________________________________________________________________

**1. Introducción**

Código utilizado:  

Procesamiento:  WRF3.6.1
Pre-procesamiento:  WPS3.6.1
Post-procesamiento: ARWpost_V3  

Para version WRF3.8 Realizar este procedimiento cambiando 3.6.1 por 3.8  #Bajo estudio en este momento

Herramienta adicional para post-procemiento: Grads
Descargado desde:
http://iges.org/grads/downloads.html

Requerimientos:  
Instalados en Mendieta:

* perl
* netcdf   
* hdf5   
* mpi  

No instalados en Mendieta:

* Jasper
Descargado desde: 
http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-1.900.1.zip  

_______________________________________________________________________________

**2. Descarga de WRF/WPS/ARWpost**

clonar este repo:
```
ssh <USER>@mendieta.ccad.unc.edu.ar
cd $HOME
git clone https://github.com/lvc0107/wrf_mendieta.git
cd wrf_mendieta
mkdir WRF3.6.1 
```


Cargar las siguientes variables de entorno

```
. set_configuration.sh
```

Descarga de WRF   
```
cd $WRF_BASE/WRF3.6.1
wget http://www2.mmm.ucar.edu/wrf/src/WRFV3.6.1.TAR.gz
tar -xvzf WRFV3.6.1.TAR.gz
rm WRFV3.6.1.TAR.gz
```

Descarga de WPS

```
cd $WRF_BASE/WRF3.6.1
wget http://www2.mmm.ucar.edu/wrf/src/WPSV3.6.1.TAR.gz
tar -xvzf WPSV3.6.1.TAR.gz
rm WPSV3.6.1.TAR.gz
```

Descarga de ARWpost

```
cd $WRF_BASE/WRF3.6.1
wget http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz 
rm ARWpost_V3.tar.gz
```

_______________________________________________________________________________

**3. Instalación de WRF + dependencias**

**3.1. Seteo de entorno**


Jasper:

```
cd $WRF_BASE

module load compilers/gcc/4.9
mkdir -p library/jasper
cd library/jasper
wget http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip
cd jasper-1.900.1
./configure --prefix=$WRF_BASE/library/jasper
make
make check
make install
```
Chequeo de la correcta instalacion de jasper:
```
ls ../bin/
imgcmp  imginfo  jasper  tmrdemo
```


**ATENCION!!! La siguiente seccion debe usarse en caso de que las dependencias de MENDIETA no esten instaladas.**  
**Actualmente las dependencias necesarias si estan instaladas por lo tanto pasamos directamente a la seccion 3.1.2.**  
**En caso de que no estuvieses instaladas seguir en la siguiente seccion. Tambien es importante cambiar "set_configuration.sh" por "set_custom_configuration.sh" en los archivos job_wrf_i.sh con i:{40,60,80,100}.**  

**3.1.1 Instalacion de tools propias (Sin usar las que provee Mendieta)**

Cargar las siguientes variables de entorno
```
. set_custom_configuration.sh
```


Zlib
```
cd $WRF_BASE/library
mkdir zlib
cd zlib
wget http://fossies.org/linux/misc/zlib-1.2.8.tar.gz
tar -xvf zlib-1.2.8.tar.gz
rm zlib-1.2.8.tar.gz
cd zlib-1.2.8/
./configure --prefix=$(pwd)
make test
make install
```

HDF5
```
cd $WRF_BASE/library
mkdir hdf5
cd hdf5/
wget https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.gz
tar -xvzf hdf5-1.8.13.tar.gz
hdf5-1.8.13.tar.gz
cd hdf5-1.8.13/
 ./configure --prefix=$(pwd)
make test
make install
make check-install
```


NETCDF
```
cd $WRF_BASE/library
mkdir netcdf
wget http://pkgs.fedoraproject.org/repo/pkgs/netcdf/netcdf-4.3.3.1.tar.gz/5c9dad3705a3408d27f696e5b31fb88c/netcdf-4.3.3.1.tar.gz
md5sum  netcdf-4.3.3.1.tar.gz | grep 5c9dad3705a3408d27f696e5b31fb88c
tar -xvf netcdf-4.3.3.1.tar.gz
rm netcdf-4.3.3.1.tar.gz
cd netcdf-4.3.3.1/
./configure --prefix=$(pwd)/.. FC=gfortran F77=gfortran CC=gcc --enable-shared LDFLAGS="-L$HOME/WRF/library/hdf5/hdf5-1.8.13/lib"  CPPFLAGS="-I$HOME/WRF/library/hdf5/hdf5-1.8.13/include"
make
make check
make install
```

NETCDF-Fortran
```
cd $WRF_BASE/library/netcdf
wget  wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.2.tar.gz
tar -xvf netcdf-fortran-4.2.tar.gz
rm netcdf-fortran-4.2.tar.gz
cd  netcdf-fortran-4.2
./configure --prefix=$(pwd)/..  FC=gfortran F77=gfortran CC=gcc --enable-shared 2>&1 | tee configure.log
make
make check
make install

```


MVAPICH
```
cd $WRF_BASE/library
mkdir mvapich
cd mvapich
wget http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-2.2.tar.gz
tar -xvf  mvapich2-2.2.tar.gz
rm mvapich2-2.2.tar.gz
cd  mvapich2-2.2
#configure: error: 'infiniband/mad.h not found. Please retry with --disable-mcast'
 ./configure --prefix=$(pwd)/.. --disable-mcast
make
make install

# Add $(pwd)/../bin to PATH
```

**3.1.2 Uso de tools instaladas en Mendieta**

```
. set_configuration.sh
```


**3.2. Instalación de WRF**

 

```
cd $WRF_DIR
./clean -a
./configure
```


Al iniciar configure debe dar un mensaje como el siguiente:   
De esta pinta si se esta usando set_configuration.sh (Herramientas provistas por Miendeta. RECOMENDADO)
```
checking for perl5... no
checking for perl... found /usr/bin/perl (perl)
Will use NETCDF in dir: /opt/netcdf-fortran/4.4.2-netcdf_4.3.3.1-gcc_4.9.2
Will use PHDF5 in dir: /opt/hdf5/1.8.15-gcc_4.9.2
which: no timex in (/opt/netcdf-fortran/4.4.2-netcdf_4.3.3.1-gcc_4.9.2/bin:/opt/netcdf/4.3.3.1-gcc_4.9.2/bin:/opt/hdf5/1.8.15-gcc_4.9.2/bin:/opt/openmpi-cuda/1.8.8-gcc_4.9-cuda_7.0-clean/bin:/opt/gcc/4.9.3/bin:/opt/cuda/7.0/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/ibutils/bin:/opt/mendieta/bin:/home/alighezzolo/bin:/home/alighezzolo/conae/library/grads-2.0.2/bin)

```

O de esta pinta si se esta usando set_custom_configuration.sh
```
checking for perl... found /usr/bin/perl (perl)
Will use NETCDF in dir: /home/<USER>/wrf_mendieta/library/netCDF
Will use PHDF5 in dir: /home/<USER>/wrf_mendieta/library/hdf5-1.8.13
which: no timex in (/opt/gcc/4.9.3/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/ibutils/bin:/opt/mendieta/bin:/home/<USER>/bin

```

Verificar que las variables **NETCDF** y **PHDF5** apunten a los path seteados en los archivos set_configuration.sh (set_custom_configuration.sh). 

Elegir opciones 34-1
34. x86_64 Linux, gfortran compiler with gcc (dmpar)
Compile for nesting? (1=basic) 1


Si se va a utilizar openmpi(en lugar de mvapich), actualizar la variable DM_CC con el valor -DMPI2_SUPPORT  en el archivo configure.wrf

```
DM_CC           =       mpicc -DMPI2_SUPPORT
```


```
./compile em_real &> compile.log
```
Comprobar la generación de los siguientes archivos .exe:

```
ls -lt main/*.exe

real.exe
tc.exe
nup.exe
ndown.exe
wrf.exe
```

**3.3 Instalación de WPS**

```
cd $WPS_DIR
./clean -a
./configure
```
Notar que al iniciar debe dar un mensaje como el siguiente:

```
Will use NETCDF in dir: /home/<USER>/library/netCDF
Found Jasper environment variables for GRIB2 support...
  $JASPERLIB = /home/<USER>/wrf_mendieta/library/jasper/lib
  $JASPERINC = /home/<USER>/wrf_mendieta/library/jasper/include
```

Elegir opción 1   

Actualizar Vtable.

```
cd ungrib/Variable_Tables
wget http://www2.mmm.ucar.edu/wrf/src/Vtable.GFS_new
cd ../../
ln -s ungrib/Variable_Tables/Vtable.GFS_new Vtable
```


```
./compile &> compile.log
```
Comprobar la generación de los siguientes archivos .exe:

```
ls -lt *.exe
```

```
metgrid.exe -> metgrid/src/metgrid.exe
ungrib.exe -> ungrib/src/ungrib.exe
geogrid.exe -> geogrid/src/geogrid.exe
```

Copiar este script:
```
cp $WRF_BASE/link_grib.csh $WPS_DIR
```

**3.4 Instalación de ARWpost**

```
cd $ARWPOST_DIR
```
Agregar -lnetcdff en src/Makefile

```
ARWpost.exe: $(OBJS)
    $(FC) $(FFLAGS) $(LDFLAGS) -o $@ $(OBJS) 
        -L$(NETCDF)/lib -I$(NETCDF)/include -lnetcdff -lnetcdf
```


```
./clean -a
./configure
```
Elegir opción 3.

```
./compile
```
Comprobar la generación del siguiente archivo .exe:
 
```
ls *.exe 
ARWpost.exe 
```

**3.5 Instalación de grads**

```
cd $WRF_BASE/library
wget http://cola.gmu.edu/grads/downloads/grads-2.0.2-bin-CentOS5.8-x86_64.tar.gz
tar -xvzf grads-2.0.2-bin-CentOS5.8-x86_64.tar.gz
rm grads-2.0.2-bin-CentOS5.8-x86_64.tar.gz
cd grads-2.0.2
mkdir data
cp data2.tar.gz .
tar xvf data2.tar.gz
TODO explicar de donde obtener el arhivo data2.tar.gz (por ahora lo provee Andres)
```

_________________________________________________________________________

**4. Obtención de datos terrestres**

```
cd $WPS_DIR
mkdir geog
cd geog
wget http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_complete.tar.bz2
tar -xjvf geog_complete.tar.bz2
rm geog_complete.tar.bz2

#datos adicionales
wget http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_gmted2010_30s.tar.bz2
tar -xjvf topo_gmted2010_30s.tar
rm topo_gmted2010_30s.tar

wget http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_30s.tar.bz2
tar -xjvf topo_30s.tar.bz2
rm  topo_30s.tar.bz2

wget http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_21class_30s.tar.bz2
tar -xjvf modis_landuse_21class_30s.tar.bz2
rm modis_landuse_21class_30s.tar.bz2
```
Actualizar namelist.wps con path al directorio recien creado

```
cd $WRF_BASE/scenarios
#Edit namelist.wps
geog_data_path = ‘/home/<USER>/wrf_mendieta/<WRF_VERSION>/WPS/geog’ # <USER> y <WRF_VERSION> que correspondan
```
_________________________________________________________________________
**5. Ejecucion del modelo**

Configuración de entorno:

```
cd $WRF_BASE/
mkdir gribfiles
```
**5.1. Crear el directorio scenarios con la siguiente estructura:**

```
tree scenarios
├── Scenario1
│   ├── namelist.ARWpost
│   └── namelist.input
├── Scenario2
│   ├── namelist.ARWpost
│   └── namelist.input
├── Scenario3
│   ├── namelist.ARWpost
│   └── namelist.input
│   .
│   .
│   .
├── ScenarioN
│   ├── namelist.ARWpost
│   └── namelist.input
├── gradfile1.gs
├── gradfile2.gs
├── .
├── .
├── .
├── gradfileN.gs
└── namelist.wps
```

Ejemplo usado para CAEARTE  
```
tree scenarios
├── A_Thompson_MYJ
│   ├── namelist.ARWpost
│   └── namelist.input
├── B_Marrison_MYJ_sf_sfclay_physics
│   ├── namelist.ARWpost
│   └── namelist.input
├── cbar.gs
├── C_WDM6_QNSE_sf_sfclay_physics
│   ├── namelist.ARWpost
│   └── namelist.input
├── D_WRF6_MYJ_sf_sfclay_physics
│   ├── namelist.ARWpost
│   └── namelist.input
├── E_WDM6_MYNN3
│   ├── namelist.ARWpost
│   └── namelist.input
├── HPC_CBA_Rain.gs
├── HPC_CBA_Tmax_Min.gs
├── meteogramas_Preciptation.gs
├── meteogramas_rh.gs
├── meteogramas_Temp.gs
├── meteogramas_WindDir.gs
├── meteogramas_WindSpeed.gs
├── namelist.wps
└── rgbset.gs
```

**5.2 Correr script: run_wrf_model.py**   
Este script realiza las siguientes tareas:   
1) Descarga grib files dada una fecha en el directorio gribfiles en el step anterior    
2) Actualiza fecha en namelist.wps en el directorio scenarios      
3) Actualiza fecha en los namelist.input dentro de cada directorio scenarios/Scenarioi con i:{1..N}     
4) Actualiza fecha en namelist.arwPost dentro de cada directorio scenarios/Scenarioi con i:{1..N}     
5) Ejecuta el modelo para cada uno de los scenarios  

```
python run_wrf_model.py --start_date=STARTDATE --offset=OFFSET --cores=40
```

El script ejecuta los 5 scenarios en paralelo corriendo WRF en 2 nodos de la partición capability(40 cores en total).   

Se ejecutan los 5 modelos en dos nodos -20 cores p/nodo
sbatch ./job_wrf_40.sh

Ejemplo:

```
python run_wrf_model.py --start_date=2016102000 --offset=36 --cores=40
```

Nota: 
Ajustar el tiempo de ejecución del modelo en el script job_wrf.sh de la forma mas precisa posible.
Ejemplo si la ejecución del modelo toma aproximadamente (poco menos que) una hora y media:

```
SBATCH --time 0-1:30
```

La ejecución genera los output en los directorios:
```
$WRF_BASE/output/<fecha_actual>/<JOB_ID>
```

La ejecución genera logs en los directorios:
```
$WRF_BASE/logs/<fecha_actual>/$RUN_PARAMETERS'_'$SLURM_JOB_ID.out
```
donde RUN_PARAMETERS esta definido en el script job_wrf_N.sh  # con N en [40, 60, 80, 100]    


Tambien se pueden ejecutar los scripts:  
```
job_wrf_60.sh  
job_wrf_80.sh   
job_wrf_100.sh   
```
Que ejecutan los scenarios usando 3,4 y 5 nodos de 20 cores c/u respectivamente

```
python run_wrf_model.py --start_date=2016102000 --offset=36 --cores=60
python run_wrf_model.py --start_date=2016102000 --offset=36 --cores=80
python run_wrf_model.py --start_date=2016102000 --offset=36 --cores=100
```


Importante: La quota por usuario es de 500GB. Por lo tanto es necesario limpiar(borrar) los resultados que se van generando periodicamente, luego de su procesamiento.

**6. Bibliografía & Guías de instalación tomadas de referencia**

[1] http://forum.wrfforum.com/viewtopic.php?f=5&t=7099   
[2] http://www.unidata.ucar.edu/software/netcdf/docs/building_netcdf_fortran.html   
[3] http://www2.mmm.ucar.edu/wrf/users/docs/user_guide_V3/users_guide_chap2.htm#_Required_Compilers_and_1   
[4] http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP5   
[5] http://www2.mmm.ucar.edu/wrf/users/FAQ_files/FAQ_wrf_installation.html

