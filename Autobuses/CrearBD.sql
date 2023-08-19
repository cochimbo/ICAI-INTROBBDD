#EXPORTAR DATOS A UN FICHERO: (si deseamos salvar datos a un fichero)
#-----------------------------
#select * from AUTOBUSES INTO outfile '/tmp/autobuses';
#select * from PASAJEROS INTO outfile '/tmp/pasajeros';
#select * from TRAYECTOS INTO outfile '/tmp/trayectos';
#select * from BILLETES INTO outfile '/tmp/billetes';

#CREACIÓN BDs:
#---------------------
DROP DATABASE IF EXISTS BDAUTOBUSES;
CREATE DATABASE IF NOT EXISTS BDAUTOBUSES;
USE BDAUTOBUSES;

#CREACIÓN DE TABLAS:
#---------------------
DROP TABLE IF EXISTS PASAJEROS;
DROP TABLE IF EXISTS AUTOBUSES;
DROP TABLE IF EXISTS TRAYECTOS;
DROP TABLE IF EXISTS BILLETES;



CREATE TABLE PASAJEROS (
  DNI varchar(10) NOT NULL,
  NOMBRE varchar(25),
  TLFN varchar(9),
  PRIMARY KEY (DNI)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 


CREATE TABLE AUTOBUSES (
  MATRIC varchar(10) NOT NULL,
  NASIENTOS int(11) ,
  ITV date ,
  PRIMARY KEY (MATRIC)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE TRAYECTOS (
  CODTRAY varchar(10) NOT NULL,
  ORIG varchar(15),
  DEST varchar(15),
  PRECIO decimal(4,2),
  KM int(11),
  PRIMARY KEY (CODTRAY)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 


CREATE TABLE BILLETES (
  CBILL int(11) NOT NULL,
  CODTRAY char(8) NOT NULL,
  MATRIC char(7) NOT NULL,
  DNI char(10) NOT NULL,
  FECHA date DEFAULT NULL,  # POR DEFECTO TOMA NULO SI NO LE DOY VALOR
  HORA time,
  PRIMARY KEY (CBILL),
  KEY CODTRAY (CODTRAY),
  KEY MATRIC (MATRIC),
  KEY DNI (DNI),
  CONSTRAINT BILLETES_ibfk_1 FOREIGN KEY (CODTRAY) REFERENCES TRAYECTOS (CODTRAY) ON DELETE CASCADE,
  CONSTRAINT BILLETES_ibfk_2 FOREIGN KEY (MATRIC) REFERENCES AUTOBUSES (MATRIC) ON DELETE CASCADE,
  CONSTRAINT BILLETES_ibfk_3 FOREIGN KEY (DNI) REFERENCES PASAJEROS (DNI) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 


#IMPORTAR DATOS DESDE UN FICHERO:
#--------------------------------
LOAD DATA LOCAL INFILE 'pasajeros' INTO TABLE PASAJEROS;
LOAD DATA LOCAL INFILE 'autobuses' INTO TABLE AUTOBUSES;
LOAD DATA LOCAL INFILE 'trayectos' INTO TABLE TRAYECTOS;
LOAD DATA LOCAL INFILE 'billetes' INTO TABLE BILLETES;
