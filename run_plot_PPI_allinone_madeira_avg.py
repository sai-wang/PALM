# script for plotting of lidar data from netcdf files on polar plot
# by LEOSPHERE, contact: Jana Preissler, jpreissler@leosphere.com, June, 2020

import os
from pathlib import Path
from glob import glob

import datetime as dt

import numpy as np
import pandas as pd
from netCDF4 import Dataset
import xarray
import h5py
# from netCDF4 import Dataset
# import hdf5

import matplotlib.pyplot as plt
import matplotlib.dates as dates
import seaborn as sns
import imageio

import pdb

import PPI_plot_config_madeira_avg as vc

# set font size of figures
sns.set(font_scale=1.3, style="white")
#20220705 Sai Wang: Disable warnings from line 240
pd.options.mode.chained_assignment = None  # default='warn'

#### FUNCTIONS ####

def main():
    # find date range
    when_start = vc.when_start
    when_end = vc.when_end
    days_diff = when_end-when_start
    next_day = when_start
    dflid_old = pd.DataFrame()
    dflid = pd.DataFrame()
    dflid_ref = pd.DataFrame()
    # loop until end date
    while True:
        if next_day > when_end:
            break

        # read lidar data (new scan pattern)
        name_lid = vc.name_lid_pre + dt.datetime.strftime(next_day, vc.dt_lid_format) + vc.name_lid_post
        dflidone = get_lidar_data(vc.where_lid, name_lid, vc)
        
        # append daily data
        dflid = pd.concat([dflid, dflidone], sort=True)

        next_day += dt.timedelta(days=1)

    # uncomment next line to restrict plotting to a specific scan ID
#    pdb.set_trace()
#    dflid = dflid[dflid['scanID']==133]
    run_loop(dflid, 'all', '2S')


def run_loop(dflid, nameadd, t):

    # find time string for file names
    days_diff = dflid.index.get_level_values(0)[-1] - dflid.index.get_level_values(0)[0]
    if days_diff.days >=1:
        datestr = dt.datetime.strftime(dflid.index.get_level_values(0)[0], '%Y%m%d_') + str(days_diff.days+1) + '_days_' + nameadd
    else:
        datestr = dt.datetime.strftime(dflid.index.get_level_values(0)[0], '%Y%m%d_%H%M%S_') + nameadd

    # check if output path exists, create if not
    if not os.path.isdir(vc.outpath):
        os.mkdir(vc.outpath)
    
    # plot CNR
    # c = 'cnr'
    # clim = vc.cnr_range
    
    #plot radial wind speed
    c = 'radial_wind_speed'
    clim = vc.u_range
    plot_low_scan(dflid, c, clim, datestr, vc)
    # two different ways of time-height plots
#   plot_ts(dflid, c, vc.cnr_range, vc.outpath, datestr + '_' + c + '_pcolor')
#   plot_scatter_ts(dflid, c, vc.cnr_range, vc.outpath, datestr + '_' + c + '_scatter')

    print('DONE')

    return

## IO ##
def read_lidar(infile):
    # opens netcdf file containing lidar radial wind
    # input is file name as string
    # returns pandas data frame

    # use x array to open and read the netcdf file
    xds = xarray.open_dataset(infile, decode_times=True, engine="netcdf4").transpose()
    xgrname = xds['sweep_group_name'].values[0]
    xds.close()
    xgr = xarray.open_dataset(infile, group=xgrname, decode_times=False).transpose()
    # convert to pandas data frame
    dfnc = xgr.to_dataframe().reset_index()
    xgr.close()
    dfnc['time'] = pd.to_datetime(dfnc.time,unit='s')
    # set and sort index
    dfnc = dfnc.set_index(['time','range']).sort_index()
    # remove columns of string (object)
    dfnc = dfnc[dfnc.T[dfnc.dtypes!=object].index]
    # remove columns that are not needed
    if 'fixed' in infile.name:
        dfred = dfnc.drop(columns=['ray_angle_resolution', 'range_gate_length', \
                             'ray_accumulation_time','sweep_index', \
                             'ray_index','gate_index','doppler_spectrum_width', \
                             'doppler_spectrum_mean_error','azimuth', \
                             'atmospherical_structures_type', \
                             'relative_beta','instrumental_function_x_max', \
                             'instrumental_function_y_average','instrumental_function_amplitude',\
                             'instrumental_function_half_height_width','instrumental_function_status'])
    elif 'dbs' in infile.name:
        try:
            dfred = dfnc.drop(columns=['gate_index', 'ray_angle_resolution', 'range_gate_length', \
                             'ray_accumulation_time', 'sweep_index', 'ray_index', 'measurement_height', \
                             'doppler_spectrum_width', 'doppler_spectrum_mean_error', \
                             'atmospherical_structures_type', \
                             'relative_beta', 'instrumental_function_x_max', \
                             'instrumental_function_y_average', 'instrumental_function_amplitude', \
                             'instrumental_function_half_height_width', 'instrumental_function_status'])
        except KeyError:
            dfred = dfnc.drop(columns=['gate_index', 'ray_angle_resolution', 'range_gate_length', \
                             'ray_accumulation_time', 'sweep_index', 'ray_index', 'measurement_height', \
                             'doppler_spectrum_width', 'doppler_spectrum_mean_error'])
    elif 'ppi' in infile.name:
        dfred = dfnc.drop(columns=['ray_angle_resolution', 'range_gate_length', \
                             'ray_accumulation_time','sweep_index', \
                             'ray_index','gate_index'])
    
    return dfred


def get_lidar_data(fp, fn, vc):
    # if switched on, checks if df is already there in hdf format and gets data from there
    # if not, opens lidar files individually and reads data

    # specify name of hdf file
    hdfname = fn.replace("*", "all").replace('.nc', '.hdf')
    hdfpath = os.path.join(fp, hdfname)
    if vc.SWITCH_HDF and os.path.isfile( hdfpath ):
        print('.. reading hdf file ' + hdfpath)
        df = pd.read_hdf(hdfpath, key='df')
    else:
        df = pd.DataFrame()
        for f in Path(fp).rglob(fn):
            dfone = read_lidar( f )
            df = pd.concat([df, dfone])
        # remove run-up time
        if vc.SWITCH_MODE:
            # find time gaps larger than 1 min
            # then, other scans were performed and mode has changed
            df['diffs'] = False
            ixcol = np.where(df.columns=='diffs')[0]
            df.iloc[1:,ixcol] = np.diff(df.index.get_level_values('time'))>np.timedelta64(60,'s')
            df.iloc[-1,ixcol] = True
            gap = df[df['diffs']]
            # discard first x seconds after each gap
            dfreduced = pd.DataFrame()
            g0 = df.index.get_level_values('time')[0]
            for g in gap.index.get_level_values('time'):
                try:
                    dfdisc = df.unstack('range')
                except ValueError:
                    df = df[~df.index.duplicated()]
                    dfdisc = df.unstack('range')
                dfdisc = dfdisc[(dfdisc.index>=g0) & (dfdisc.index<g)].stack('range',dropna=False)
                dfdisc = vt.discard_runup_time(dfdisc, vc)

                dfreduced = pd.concat([dfreduced, dfdisc])
                g0 = g

            df = dfreduced

        print('.. writing data frame of lidar data to hdf file ' + hdfpath)
        df.to_hdf(hdfpath, key='df', mode='w')

    return df


## PLOTTING
def plot_low_scan(toplot, sProp, clim, sDate, vc):
    # plots low level scan on polar grid

    if len(toplot)>0:
        print('... plotting PPI, ' + sProp)
        try:
            toplot = toplot.unstack().stack()
        except IndexError:
            toplot = toplot

        toplot = toplot.sort_index()
        toplot['azimuth'] = np.radians(round(toplot['azimuth']))
        if 'scanID' in toplot:
            for sID in toplot['scanID'].unique():
                dfplot = toplot[toplot['scanID']==sID]
                plot_ppi_loop(dfplot, sProp, clim, sDate, vc, sID)
        else:
            plot_ppi_loop(toplot, sProp, clim, sDate, vc, vc.scan_ID)


def plot_ppi_loop(dfplot, sProp, clim, sDate, vc, sID):
            # time difference of 59 seconds (in ns)
            # 20220705 Sai Wang: Madeira airport scans did 180¤, time interval of some scans slightly larger than 1s, so set 10s
            newscan = np.where(np.diff(dfplot.index.get_level_values('time')).astype(float) > vc.tgap*10000000000)
            # newscan = np.where(np.diff(dfplot.index.get_level_values('time')).astype(float) > vc.tgap*1000000000)
            newscan = newscan[0]
            nameadd = sProp + '_' + str(sID)

            n = 0
            if len(newscan)==0:
                newscan = [len(dfplot)]
            if newscan[0]==0 and len(newscan)>1:
                    newscan = newscan[1:]
                    n = 1
            # add last scan
            newscan = list(newscan) + [len(dfplot)+1]

            for s in newscan:
                fig=plt.figure(figsize=(10, 5))
                sns.set(font_scale=1.1, style="white")
                # plot horizontal scan from n to s
                thisscan=dfplot[n+1:s-1]
                # do not attempt to plot empty scans
                if thisscan.empty:
                    return

                # discard background (low confidence index)
                if 'confidence_index' in thisscan:
                    thisscan = thisscan[thisscan.confidence_index>=vc.no_ci]#.status==1]#
                sTitle = 'scan on ' + thisscan.index[0][0].strftime('%Y/%m/%d')\
                        + ' from ' + thisscan.index[0][0].strftime('%H:%M:%S')\
                        + ' to ' + thisscan.index[-1][0].strftime('%H:%M:%S')

                # separate range and azimuth angle index arrays
                thisscan.drop_duplicates(inplace=True)
                # thisscan['azimuth'] = round(thisscan['azimuth'])
                try:
                    
                    # 20231221 Sai Wang: for consecutive PPI/RHI scans, round azimuth angles for plotting average scans
                    bpivot = thisscan.reset_index().pivot_table(index='azimuth',columns='range',values=sProp)
                except ValueError:
                    plotthis = thisscan.reset_index().set_index(['azimuth','range'])
                    plotthis = plotthis[plotthis.index.duplicated(keep='first')]
                    bpivot = plotthis.reset_index().pivot(index='azimuth',columns='range',values=sProp)
                    pdb.set_trace()
    

                # plotting
                ax = plt.subplot(111, polar=True)
                ax.grid(False)
                plt.title( sTitle )
                plotarr = np.ma.masked_invalid(bpivot.values.T)
                cp =  plt.pcolormesh(bpivot.index.values, bpivot.columns.values,\
                        plotarr, edgecolors='none', cmap='bwr', vmin=clim[0], vmax=clim[1] )
                cb = plt.colorbar(cp)
                cb.set_label(sProp)
                ax.set_ylim(vc.range_range)
                ax.set_theta_zero_location('N')
                ax.set_theta_direction(-1)
                # uncomment and adjust the next three lines to zoom in
#               ax.set_rorigin(-1000)
#               ax.set_thetamin(265)
#               ax.set_thetamax(298)
                plt.grid(visible=True, which='both')
                # save plot
                plt.savefig(os.path.join(vc.outpath, sDate + '_' + thisscan.index[0][0].strftime('%y%m%d%H%M%S') + '_' + nameadd + '_ppi.png'), dpi=200)
                plt.close()
                n=s

            # if sProp!='tele':
            #     try:
            #         filenameadd = nameadd + '_ppi.png'
            #         outnameadd = nameadd + '_ppi.gif'
            #         create_gif(filenameadd, sDate, outnameadd, vc)
            #     except RuntimeError:
            #         print('... RuntimeError while creating PPI gif')
            #     except IndexError:
            #         print('... IndexError while creating PPI gif')


def create_gif(filenameadd, sDate, outnameadd, vc):
    # creates gif from RHI and low level scans
    print('.. plotting gif')
    filenames = sorted(glob(os.path.join(vc.outpath, sDate[0:8] + '_*_' + filenameadd)))
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    output_file = os.path.join(vc.outpath, sDate + '_' + outnameadd)
    imageio.mimsave(output_file, images, duration=1)
    print('.. gif is ready')

    return


def plot_ts(df, C, vlims, outp, outname):
    # plots time-height plots of variable C
    dfplot = df[C].unstack().T
    xdata = dfplot.columns.values
    ydata = dfplot.index.values

    plt.figure(figsize=(10, 5))
    plt.pcolor(xdata, ydata, dfplot, vmin=vlims[0], vmax=vlims[1])
    cb = plt.colorbar()
    cb.set_label(C)

    ax = plt.gca()
    ax.xaxis.set_major_formatter(dates.DateFormatter('%H:%M'))

    plt.xlim([xdata[0], xdata[-1]])
    plt.ylim([ydata[0], ydata[-1]])

    plt.xlabel(df.index.names[0])
    plt.ylabel(df.index.names[1])
    
    plt.tight_layout()
    plt.savefig(os.path.join(outp,outname + '.png'))
    plt.close()


def plot_scatter_ts(df, C, vlims, outp, outname):
    # plots time-height plots of variable C
    plt.figure(figsize=(10, 5))
    cp = plt.scatter(df.index.get_level_values('time'), df.index.get_level_values('range'), c=df[C], vmin=vlims[0], vmax=vlims[1])
    cb = plt.colorbar(cp)
    cb.set_label(C)

    ax = plt.gca()
    ax.xaxis.set_major_formatter(dates.DateFormatter('%H:%M'))

#    plt.xlim([xdata[0], xdata[-1]])
#    plt.ylim([ydata[0], ydata[-1]])

    plt.xlabel(df.index.names[0])
    plt.ylabel(df.index.names[1])
    
    plt.tight_layout()
    plt.savefig(os.path.join(outp,outname + '.png'))
    plt.close()


#### RUN ####

if __name__ == "__main__":
   main()
