# MQ_Data_Preparation

**MATLAB** script for preparation and processing of lunar seismic data from the **Apollo** missions.

The script processes **LP (Long Period)** and **SP (Short Period)** records obtained from the shallow moonquake catalog and data downloaded from **DARTS (JAXA)**. The workflow includes record extraction, preprocessing, instrumental response deconvolution, and generation of output files and PDF plots.

---

## 📋 Overview

For each event included in the catalog, `MQ_Data_Preparation.m` runs a processing workflow comprising:

1. Creation of a directory structure organized by event and record type.
2. Optional download of CSV files from DARTS.
3. Extraction of signals by station and component.
4. Signal preprocessing:
   - Time-window trimming.
   - Resampling.
   - `detrend`.
   - Spike removal using `hampel`.
5. Instrumental response deconvolution.
6. Computation of:
   - Acceleration.
   - Velocity.
   - Displacement.
7. Saving results to `.txt` files.
8. Generation of PDF plots for different processing stages.

---

## 🔬 Record types

The script processes two seismic record types:

| Type | Description | Components |
|---|---|---|
| **LP** | Long Period | X, Y, Z |
| **SP** | Short Period | Z |

Data are processed independently for each event, station, and component.

---

## 🛠️ Requirements

### MATLAB

A MATLAB version compatible with the functions used by the script is required, including:

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

The script uses functions from the following toolboxes:

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

### Input files

The working directory must contain:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

In addition, the CSV files from DARTS must be available in the `01-Darts` folders, unless automatic downloading is enabled.

---

## 📁 Directory structure

The program creates a main folder named `Darts_Data_Preparation`.

Inside it, one folder is created for each catalog event:

```text
Darts_Data_Preparation/
│
└── <Event>/
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

> **Note:** The structure created for LP uses the `Des` folder, while `SaveDeconvolved` uses `Dis` to save displacement. This inconsistency is documented in the known limitations section.

---

## 🔄 Processing workflow

The processing can be represented in simplified form as:

```text
                 Shallow_Catalog.txt
                         │
                         ▼
               ┌───────────────────┐
               │   Initialization  │
               └─────────┬─────────┘
                         │
                         ▼
              Creation of directories
                         │
                         ▼
                ┌─────────────────┐
                │ DARTS data      │
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

## ⚙️ Main stages

### 1. Initialization

The script:

- Clears the MATLAB environment.
- Starts a timer.
- Creates a `diary.txt` file.
- Logs the execution date and time.
- Reads:
  - `Shallow_Catalog.txt`
  - `Flat_Mode_Operation_Term.txt`
- Creates the main directory `Darts_Data_Preparation`.

---

### 2. Directory creation

For each catalog event, independent structures are created for:

- `LP`
- `SP`

Each record type contains the stages:

```text
01-Darts
02-Extracted
03-PreProcessed
04-Deconvolved
```

---

### 3. DARTS data download

The function:

```matlab
DartsDownload(...)
```

builds requests to download hourly records from the DARTS server.

Currently, the call to this function is commented out in the main workflow:

```matlab
%DartsDownload(...)
```

Therefore, the CSV files must already be available in `01-Darts`, unless downloading is enabled.

---

### 4. Record extraction

The function:

```matlab
RecordExtraction(...)
```

reads the CSV files and groups the data by station.

For **LP** records it extracts:

```text
LPX
LPY
LPZ
```

For **SP** records it extracts:

```text
SPZ
```

The extracted data contain:

```text
Time [s]    Amplitude [DU]
```

For LP, the three components are stored:

```text
Time    LPX    LPY    LPZ
```

Whereas for SP the following is stored:

```text
Time    SPZ
```

---

### 5. Saving extracted records

The function:

```matlab
SaveExtracted(...)
```

generates files with the format:

```text
02-<Event>-<Station>-<Component>.txt
```

It also generates a PDF plot of the record inside:

```text
02-Extracted/Plot/
```

---

### 6. Preprocessing

The function:

```matlab
PreProcessing(...)
```

performs the following operations:

1. Determines the time window corresponding to the event.
2. Trims the record.
3. Resets the initial time to `t = 0`.
4. Resamples the signal.
5. Removes samples with non-increasing times.
6. Applies `detrend`.
7. Uses `hampel` for spike removal.
8. Applies `detrend` again.

The sampling intervals used are:

| Record | Interval used | Frequency |
|---|---:|---:|
| LP | `0.15094 s` | `1 / 0.15094 Hz` |
| SP | `0.018868 s` | `1 / 0.018868 Hz` |

The preprocessed records are stored in:

```text
03-PreProcessed/
```

and their plots in:

```text
03-PreProcessed/Plot/
```

---

### 7. Deconvolution

The function:

```matlab
Deconvolution(...)
```

performs deconvolution of the instrumental response.

The procedure generates three quantities:

```text
Acceleration
Velocity
Displacement
```

The instrumental response is represented using transfer functions with:

```matlab
tf(...)
```

and its response is obtained using:

```matlab
lsim(...)
```

Deconvolution is performed in the frequency domain using the Fourier transform.

For **LP** records, the script considers two modes:

```text
P = Periodic
F = Flat
```

The mode used is determined from `Flat_Mode_Operation_Term.txt`.

For **SP** records, the regularization parameter `k` is adjusted using:

```matlab
particleswarm
```

---

### 8. Post-filtering

After deconvolution, a band-pass filter is applied.

For LP:

```matlab
butter(8,...,'bandpass')
```

For SP:

```matlab
butter(6,...,'bandpass')
```

Then the following are applied again:

```text
filtfilt
detrend
hampel
detrend
```

---

### 9. Saving deconvolved results

The function:

```matlab
SaveDeconvolved(...)
```

saves three types of results.

#### Acceleration

```text
04-Deconvolved/
└── Acc/
    └── Acc*.txt
```

Unit:

```text
m·s⁻²
```

#### Velocity

```text
04-Deconvolved/
└── Vel/
    └── Vel*.txt
```

Unit:

```text
m·s⁻¹
```

#### Displacement

```text
04-Deconvolved/
└── Dis/
    └── Dis*.txt
```

Unit:

```text
m
```

PDF plots are also generated, including:

- Time series.
- Power Spectral Density (PSD).

---

## 📊 Output files

### Extracted data

```text
02-*.txt
```

Contains:

```text
Time [s]
Amplitude [DU]
```

### Preprocessed data

```text
03-*.txt
```

Contains:

```text
Time [s]
Amplitude [DU]
```

### Deconvolved data

```text
Acc/Acc*.txt
Vel/Vel*.txt
Dis/Dis*.txt
```

Contains respectively:

```text
Time [s]    Acceleration [m·s⁻²]
Time [s]    Velocity [m·s⁻¹]
Time [s]    Displacement [m]
```

### Plots

Plots are stored in the corresponding `Plot` folders.

Plots from the preprocessing and deconvolution stages include **Power Spectral Density (PSD)** analysis using `pwelch`.

---

## 🧩 Main functions

| Function | Description |
|---|---|
| `DartsDownload` | Downloads hourly CSV files from the DARTS server. |
| `RecordExtraction` | Reads the CSVs and extracts records by station and component. |
| `SaveExtracted` | Saves extracted records and generates their plots. |
| `PreProcessing` | Trims, resamples, and cleans the signals. |
| `SavePreProcessed` | Saves preprocessed records and generates plots with PSD. |
| `Deconvolution` | Performs instrumental deconvolution and obtains acceleration, velocity, and displacement. |
| `SaveDeconvolved` | Saves deconvolved results and generates the corresponding plots. |

---

## ▶️ Usage

### 1. Prepare the files

Place in the MATLAB working directory:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

### 2. Prepare the DARTS data

Place the corresponding CSV files inside the folders:

```text
01-Darts/
```

or enable the call to:

```matlab
DartsDownload(...)
```

if you want to use automatic downloading.

### 3. Run the script

From MATLAB:

```matlab
MQ_Data_Preparation
```

### 4. Review the results

After processing finishes, the following will have been generated:

```text
Darts_Data_Preparation/
```

with a structure organized by event, record type, and processing stage.

Also generated:

```text
diary.txt
```

which contains the execution log.

---

## ⚠️ Known limitations

### `readtable` and `Format`

The script uses:

```matlab
readtable(...,'Format',...)
```

in the initial reading of catalog files.

Depending on the MATLAB version/compatibility used during development, this usage may produce an error. It is recommended to review how these files are read, for example using `textscan` or a compatible `readtable` configuration.

---

### Path separators

The script uses Windows-specific separators, for example:

```matlab
'\'
```

in several file and directory operations.

This limits portability to Linux and macOS.

A more portable alternative is to use:

```matlab
fullfile(...)
```

to construct paths.

---

### Silent error handling

There are multiple blocks:

```matlab
try
    ...
catch
    % Nothing to do
end
```

that do not display information about the produced error.

This can make it harder to identify problems during processing.

---

### `nfft`

In several plots, the following is used:

```matlab
nfft = 2^(nextpow2(N)-7);
```

For sufficiently short records, this expression may produce an invalid value or a value less than 1.

It is recommended to add a minimum size check before using `pwelch`.

---

### `Des` / `Dis` inconsistency

The directory structure for LP creates:

```text
Des/
```

but `SaveDeconvolved` uses:

```matlab
Dis\
```

to save displacement.

This constitutes an inconsistency between the created structure and the path used during saving.

---

### MATLAB Toolbox dependencies

If any of the required toolboxes is not installed, certain operations may fail.

The use of empty `try/catch` blocks may prevent some of these errors from being immediately visible.

---

### Automatic download disabled

The function:

```matlab
DartsDownload(...)
```

is implemented, but its call is commented out in the main workflow.

Therefore, the CSV files are currently expected to be available beforehand.

---

### Filename parsing

Some parts of the processing depend on specific positions within the filename, for example:

```matlab
filename(5:6)
filename(10:11)
filename(13:14)
filename(15)
```

This makes processing depend on a specific filename format.

A system based on explicit identification using `strsplit`, regular expressions, or ID lookup could be more robust.

---

### Plot limits

In `SaveExtracted`, the vertical axis is set using:

```matlab
axis([0 xmax 0 ymax]);
```

This sets the lower Y-axis limit to zero and may hide negative signal values.

---

## 📚 Related files

Processing mainly depends on:

```text
Shallow_Catalog.txt
Flat_Mode_Operation_Term.txt
```

and on the CSV records downloaded from DARTS.

---

## 👤 Author

**Not specified in the original file.**

Add here the corresponding information for the project author(s).

---

## 📄 License

**Not specified in the original file.**

Add here the license under which the code is distributed.

---

## 📝 Project status

`MQ_Data_Preparation.m` constitutes a MATLAB processing workflow for preparing Apollo lunar seismic records, from original data to deconvolved acceleration, velocity, and displacement signals, together with their graphical representations and PSD analysis.
