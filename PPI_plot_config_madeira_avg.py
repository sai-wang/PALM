# this is a config file for all variable input into the validation scripts
# by LEOSPHERE, contact: Jana Preissler, jpreissler@leosphere.com, November 2019

import datetime as dt
import os


# process data from specific date (for case studies)
when_start = dt.datetime.strptime('2022-01-01', '%Y-%m-%d')
when_end= dt.datetime.strptime('2022-12-31', '%Y-%m-%d')
#when = dt.datetime.strptime('20191116_00', '%Y%m%d_%H')

###
SWITCH_HDF = True
SWITCH_MODE = False

# scan ID of fixed lidar scan
scan_ID = 133
# settings of all scans, first index is the scan_ID above
scan_dict = {35:{'res': 25, 'acct':1000, 'disp': 5, 'theo':1.0},
             37:{'res': 25, 'acct':1000, 'disp': 5, 'theo':1.0},
             133:{'res': 50, 'acct':1000, 'disp': 50, 'theo':1.0},
             }
# res ... range resolution
# acct ... accumulation time
# disp ... display resolution
# theo ... theorectical maximum of data availability (if 4 scans are performed for same time intervals, theo=1/4

# time gap between successive PPIs of the same scan ID in seconds
tgap = 1

# directory and name structure of wind lidar data file
where_lid = r"X:\Madeira data\LPMA\Windgust_all_2022\PPI"
name_lid_pre = 'WLS100s-191_'
name_lid_post = '*_ppi_' + str(scan_ID) + '_50m.nc'
dt_lid_format = '%Y-%m-%d'

# output directory
outstr = r"X:\Madeira data\LPMA\Windgust_all_2022\PPI_avg_output"
outpath = os.path.join(outstr, 'scan_ID_' + str(scan_ID))

# plotting ranges
# wind speed
u_range = [-15, 15, 1]
# wind direction
dir_range = [0, 360, 15]
# vertical wind
w_range = [-5, 5, 0.2]
# CI
ci_range = [0, 100]
# CNR
cnr_range = [-30, -15, 2]
# difference
diff_range = [-5, 5]
# difference
reldiff_range = [-1, 1]
# range
range_range = [0, 6000]

