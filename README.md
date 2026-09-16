# MQ_Data_Preparation

Script de **MATLAB** para la preparación y procesamiento de datos sísmicos lunares de las misiones **Apollo**.

El script procesa registros **LP (Long Period)** y **SP (Short Period)** obtenidos a partir del catálogo de moonquakes someros y de los datos descargados desde **DARTS (JAXA)**. El flujo incluye extracción de registros, preprocesamiento, deconvolución de la respuesta instrumental y generación de archivos de resultados y gráficas en formato PDF.

---

## 📋 Descripción general

Para cada evento incluido en el catálogo, `MQ_Data_Preparation.m` ejecuta un flujo de procesamiento que comprende:

1. Creación de una estructura de directorios organizada por evento y tipo de registro.
2. Descarga opcional de los archivos CSV desde DARTS.
3. Extracción de las señales por estación y componente.
4. Preprocesamiento de las señales:
   - Recorte temporal.
   - Remuestreo.
   - `detrend`.
   - Eliminación de picos mediante `hampel`.
5. Deconvolución de la respuesta instrumental.
6. Obtención de:
   - Aceleración.
   - Velocidad.
   - Desplazamiento.
7. Guardado de los resultados en archivos `.txt`.
8. Generación de gráficas PDF de las diferentes etapas del procesamiento.

---

## 🔬 Tipos de registros

El script procesa dos tipos de registros sísmicos:

| Tipo | Descripción | Componentes |
|---|---|---|
| **LP** | Long Period | X, Y, Z |
| **SP** | Short Period | Z |

Los datos se procesan de manera independiente para cada evento, estación y componente.

---

## 🛠️ Requisitos

### MATLAB

Se requiere una versión de MATLAB compatible con las funciones utilizadas por el script, incluyendo:

- `datetime`
- `readtable`
- `hampel`
- `envelope`
- `pwelch`
- `butter`
- `filtfilt`
- `tf`
- `lsim`
- `particleswarm`

### MATLAB Toolboxes

El script utiliza funciones pertenecientes a los siguientes toolboxes:

- **Signal Processing Toolbox**
  - `hampel`
  - `envelope`
  - `pwelch`
  - `butter`
  - `filtfilt`

- **Control System Toolbox**
  - `tf`
  - `lsim`

- **Global Optimization Toolbox**
  - `particleswarm`

### Archivos de entrada

El directorio de trabajo debe contener:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

Además, deben estar disponibles los archivos CSV procedentes de DARTS en las carpetas `01-Darts`, salvo que se habilite la descarga automática.

---

## 📁 Estructura de directorios

El programa genera una carpeta principal denominada `Darts_Data_Preparation`.

Dentro de ella se crea una carpeta para cada evento del catálogo:

```text
Darts_Data_Preparation/
│
└── <Evento>/
    │
    ├── LP/
    │   │
    │   ├── 01-Darts/
    │   │
    │   ├── 02-Extracted/
    │   │   └── Plot/
    │   │
    │   ├── 03-PreProcessed/
    │   │   └── Plot/
    │   │
    │   └── 04-Deconvolved/
    │       ├── Acc/
    │       ├── Vel/
    │       ├── Des/
    │       └── Plot/
    │           ├── Acc/
    │           ├── Vel/
    │           └── Des/
    │
    └── SP/
        │
        ├── 01-Darts/
        │
        ├── 02-Extracted/
        │   └── Plot/
        │
        ├── 03-PreProcessed/
        │   └── Plot/
        │
        └── 04-Deconvolved/
            ├── Acc/
            ├── Vel/
            ├── Dis/
            └── Plot/
                ├── Acc/
                ├── Vel/
                └── Dis/
```

> **Nota:** La estructura creada para LP utiliza la carpeta `Des`, mientras que `SaveDeconvolved` utiliza `Dis` para guardar el desplazamiento. Esta inconsistencia está documentada en la sección de limitaciones conocidas.

---

## 🔄 Flujo de procesamiento

El procesamiento se puede representar de forma simplificada como:

```text
                 Shallow_Catalog.txt
                         │
                         ▼
               ┌───────────────────┐
               │   Inicialización   │
               └─────────┬─────────┘
                         │
                         ▼
              Creación de directorios
                         │
                         ▼
                ┌─────────────────┐
                │ Datos DARTS     │
                │     CSV         │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ RecordExtraction│
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ SaveExtracted   │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │  PreProcessing  │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │SavePreProcessed │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │  Deconvolution  │
                └────────┬────────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
          Acceleration Velocity Displacement
              │          │          │
              └──────────┼──────────┘
                         ▼
                ┌─────────────────┐
                │SaveDeconvolved  │
                └────────┬────────┘
                         │
                         ▼
                    PDF + TXT
```

---

## ⚙️ Etapas principales

### 1. Inicialización

El script:

- Limpia el entorno de MATLAB.
- Inicia un cronómetro.
- Crea un archivo `diary.txt`.
- Registra la fecha y hora de ejecución.
- Lee:
  - `Shallow_Catalog.txt`
  - `Flat_Mode_Operation_Term.txt`
- Crea el directorio principal `Darts_Data_Preparation`.

---

### 2. Creación de directorios

Para cada evento del catálogo se crean las estructuras independientes para:

- `LP`
- `SP`

Cada tipo de registro contiene las etapas:

```text
01-Darts
02-Extracted
03-PreProcessed
04-Deconvolved
```

---

### 3. Descarga de datos DARTS

La función:

```matlab
DartsDownload(...)
```

construye las solicitudes para descargar los registros horarios desde el servidor DARTS.

Actualmente, la llamada a esta función se encuentra comentada dentro del flujo principal:

```matlab
%DartsDownload(...)
```

Por lo tanto, los archivos CSV deben estar disponibles previamente en `01-Darts`, a menos que se habilite la descarga.

---

### 4. Extracción de registros

La función:

```matlab
RecordExtraction(...)
```

lee los archivos CSV y agrupa los datos por estación.

Para registros **LP** extrae:

```text
LPX
LPY
LPZ
```

Para registros **SP** extrae:

```text
SPZ
```

Los datos extraídos contienen:

```text
Time [s]    Amplitude [DU]
```

Para LP se almacenan las tres componentes:

```text
Time    LPX    LPY    LPZ
```

Mientras que para SP se almacena:

```text
Time    SPZ
```

---

### 5. Guardado de registros extraídos

La función:

```matlab
SaveExtracted(...)
```

genera archivos con el formato:

```text
02-<Evento>-<Estación>-<Componente>.txt
```

También genera una representación gráfica del registro en PDF dentro de:

```text
02-Extracted/Plot/
```

---

### 6. Preprocesamiento

La función:

```matlab
PreProcessing(...)
```

realiza las siguientes operaciones:

1. Determina la ventana temporal correspondiente al evento.
2. Recorta el registro.
3. Reestablece el tiempo inicial a `t = 0`.
4. Remuestrea la señal.
5. Elimina muestras con tiempos no crecientes.
6. Aplica `detrend`.
7. Utiliza `hampel` para la eliminación de picos.
8. Aplica nuevamente `detrend`.

Las frecuencias de muestreo utilizadas son:

| Registro | Intervalo utilizado | Frecuencia |
|---|---:|---:|
| LP | `0.15094 s` | `1 / 0.15094 Hz` |
| SP | `0.018868 s` | `1 / 0.018868 Hz` |

Los registros preprocesados se almacenan en:

```text
03-PreProcessed/
```

y sus gráficas en:

```text
03-PreProcessed/Plot/
```

---

### 7. Deconvolución

La función:

```matlab
Deconvolution(...)
```

realiza la deconvolución de la respuesta instrumental.

El procedimiento genera tres cantidades:

```text
Acceleration
Velocity
Displacement
```

La respuesta instrumental se representa mediante funciones de transferencia utilizando:

```matlab
tf(...)
```

y se obtiene su respuesta mediante:

```matlab
lsim(...)
```

La deconvolución se realiza en el dominio de la frecuencia mediante la transformada de Fourier.

Para registros **LP**, el script contempla dos modos:

```text
P = Periodic
F = Flat
```

El modo utilizado se determina a partir de `Flat_Mode_Operation_Term.txt`.

Para registros **SP**, el parámetro de regularización `k` se ajusta mediante:

```matlab
particleswarm
```

---

### 8. Filtrado posterior

Después de la deconvolución se aplica un filtro pasa-banda.

Para LP:

```matlab
butter(8,...,'bandpass')
```

Para SP:

```matlab
butter(6,...,'bandpass')
```

Posteriormente se aplican nuevamente:

```text
filtfilt
detrend
hampel
detrend
```

---

### 9. Guardado de resultados deconvolucionados

La función:

```matlab
SaveDeconvolved(...)
```

guarda tres tipos de resultados.

#### Aceleración

```text
04-Deconvolved/
└── Acc/
    └── Acc*.txt
```

Unidad:

```text
m·s⁻²
```

#### Velocidad

```text
04-Deconvolved/
└── Vel/
    └── Vel*.txt
```

Unidad:

```text
m·s⁻¹
```

#### Desplazamiento

```text
04-Deconvolved/
└── Dis/
    └── Dis*.txt
```

Unidad:

```text
m
```

También se generan gráficas PDF que incluyen:

- Serie temporal.
- Power Spectral Density (PSD).

---

## 📊 Archivos de salida

### Datos extraídos

```text
02-*.txt
```

Contienen:

```text
Time [s]
Amplitude [DU]
```

### Datos preprocesados

```text
03-*.txt
```

Contienen:

```text
Time [s]
Amplitude [DU]
```

### Datos deconvolucionados

```text
Acc/Acc*.txt
Vel/Vel*.txt
Dis/Dis*.txt
```

Contienen respectivamente:

```text
Time [s]    Acceleration [m·s⁻²]
Time [s]    Velocity [m·s⁻¹]
Time [s]    Displacement [m]
```

### Gráficas

Las gráficas se almacenan en las carpetas `Plot` correspondientes.

Las gráficas de las etapas de preprocesamiento y deconvolución incluyen análisis de **Power Spectral Density (PSD)** mediante `pwelch`.

---

## 🧩 Funciones principales

| Función | Descripción |
|---|---|
| `DartsDownload` | Descarga archivos CSV horarios desde el servidor DARTS. |
| `RecordExtraction` | Lee los CSV y extrae los registros por estación y componente. |
| `SaveExtracted` | Guarda los registros extraídos y genera sus gráficas. |
| `PreProcessing` | Recorta, remuestrea y limpia las señales. |
| `SavePreProcessed` | Guarda los registros preprocesados y genera gráficas con PSD. |
| `Deconvolution` | Realiza la deconvolución instrumental y obtiene aceleración, velocidad y desplazamiento. |
| `SaveDeconvolved` | Guarda los resultados deconvolucionados y genera las gráficas correspondientes. |

---

## ▶️ Uso

### 1. Preparar los archivos

Coloca en el directorio de trabajo de MATLAB:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

### 2. Preparar los datos DARTS

Coloca los archivos CSV correspondientes dentro de las carpetas:

```text
01-Darts/
```

o habilita la llamada a:

```matlab
DartsDownload(...)
```

si deseas utilizar la descarga automática.

### 3. Ejecutar el script

Desde MATLAB:

```matlab
MQ_Data_Preparation
```

### 4. Revisar los resultados

Al finalizar el procesamiento se habrá generado:

```text
Darts_Data_Preparation/
```

con una estructura organizada por evento, tipo de registro y etapa de procesamiento.

También se genera:

```text
diary.txt
```

que contiene el registro de la ejecución.

---

## ⚠️ Limitaciones conocidas

### `readtable` y `Format`

El script utiliza:

```matlab
readtable(...,'Format',...)
```

en la lectura inicial de los archivos de catálogo.

Según la documentación/compatibilidad de MATLAB utilizada durante el desarrollo, este uso puede producir un error. Se recomienda revisar la forma de lectura de estos archivos, por ejemplo utilizando `textscan` o una configuración compatible de `readtable`.

---

### Separadores de rutas

El script utiliza separadores específicos de Windows, por ejemplo:

```matlab
'\'
```

en diferentes operaciones de archivos y directorios.

Esto limita la portabilidad a Linux y macOS.

Una alternativa más portable es utilizar:

```matlab
fullfile(...)
```

para construir las rutas.

---

### Manejo silencioso de errores

Existen múltiples bloques:

```matlab
try
    ...
catch
    % Nothing to do
end
```

que no muestran información sobre el error producido.

Esto puede dificultar la identificación de problemas durante el procesamiento.

---

### `nfft`

En varias gráficas se utiliza:

```matlab
nfft = 2^(nextpow2(N)-7);
```

Para registros suficientemente cortos, esta expresión puede producir un valor inválido o menor que 1.

Se recomienda añadir una comprobación del tamaño mínimo antes de utilizar `pwelch`.

---

### Inconsistencia `Des` / `Dis`

La estructura de directorios para LP crea:

```text
Des/
```

pero `SaveDeconvolved` utiliza:

```matlab
Dis\
```

para guardar el desplazamiento.

Esto constituye una inconsistencia entre la estructura creada y la ruta utilizada durante el guardado.

---

### Dependencias de MATLAB Toolboxes

Si alguna de las toolboxes requeridas no está instalada, determinadas operaciones pueden fallar.

El uso de bloques `try/catch` vacíos puede hacer que algunos de estos errores no sean visibles inmediatamente.

---

### Descarga automática deshabilitada

La función:

```matlab
DartsDownload(...)
```

está implementada, pero su llamada se encuentra comentada en el flujo principal.

Por ello, actualmente se espera que los archivos CSV estén disponibles previamente.

---

### Parseo de nombres de archivos

Algunas partes del procesamiento dependen de posiciones específicas dentro del nombre del archivo, por ejemplo:

```matlab
filename(5:6)
filename(10:11)
filename(13:14)
filename(15)
```

Esto hace que el procesamiento dependa de un formato específico de nombres.

Un sistema basado en identificación explícita mediante `strsplit`, expresiones regulares o búsqueda por ID podría resultar más robusto.

---

### Límites de las gráficas

En `SaveExtracted` el eje vertical se establece mediante:

```matlab
axis([0 xmax 0 ymax]);
```

Esto fija el límite inferior del eje Y en cero y puede ocultar valores negativos de la señal.

---

## 📚 Archivos relacionados

El procesamiento depende principalmente de:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

y de los registros CSV descargados desde DARTS.

---

## 👤 Autor

**No especificado en el archivo original.**

Añadir aquí la información correspondiente al autor o autores del proyecto.

---

## 📄 Licencia

**No especificada en el archivo original.**

Añadir aquí la licencia bajo la cual se distribuye el código.

---

## 📝 Estado del proyecto

`MQ_Data_Preparation.m` constituye un flujo de procesamiento MATLAB para la preparación de registros sísmicos lunares Apollo, desde los datos originales hasta señales deconvolucionadas de aceleración, velocidad y desplazamiento, junto con sus representaciones gráficas y análisis PSD.
