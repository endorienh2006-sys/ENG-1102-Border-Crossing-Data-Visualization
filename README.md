# U.S. Border Crossing Data Analysis & Visualization

A MATLAB analysis of U.S. border crossing patterns using an Excel dataset of monthly port observations. This is a portfolio update of an ENGR 1102 group data-visualization mini-project.

## Scope
The source workbook includes several different measures (vehicles, passengers, trains, containers, etc.). To avoid adding incompatible units, the updated analysis **filters to `Personal Vehicles`**. It visualizes monthly trends, seasonal patterns at the U.S.–Canada and U.S.–Mexico borders, and the geographic distribution of vehicle crossings by port.

## How to run
1. Place `Border_Crossing_Entry_Data.xlsx` next to `borderCrossingAnalysis.m`.
2. Open the folder in MATLAB and run `borderCrossingAnalysis`.
3. See the generated high-resolution PNG files and port summary CSV in `results/`.

## Outputs
- `01_monthly_heatmap.png`: monthly vehicle crossings by year
- `02_border_comparison.png`: average monthly border totals by month
- `03_port_bubble_map.png`: total observed vehicle crossings by port
- `port_crossing_summary.csv`: aggregated port data

## Notes and limitations
- This is an observational visualization, not a causal analysis.
- The latest/earliest years may be incomplete, so comparisons across years require care.
- Port totals cover the observations available in the workbook, not necessarily identical reporting periods for every port.
- The geographic figure uses logarithmic bubble sizing.
- The original mini-project was completed as a group; this portfolio version modernizes the MATLAB visualization code.

## Data
`Border_Crossing_Entry_Data.xlsx` — the supplied border crossing entry dataset. Add the original source URL and access date here once verified.
