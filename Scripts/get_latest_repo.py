#!/usr/bin/env python
import sys, argparse
from json import loads
from urllib.request import urlopen, urlretrieve, Request

###############################################################################
#                                                                             #
#  888888888888        ,ad8888ba,        88888888ba,          ,ad8888ba,      #
#       88            d8"'    `"8b       88      `"8b        d8"'    `"8b     #
#       88           d8'        `8b      88        `8b      d8'        `8b    #
#       88           88          88      88         88      88          88    #
#       88           88          88      88         88      88          88    #
#       88           Y8,        ,8P      88         8P      Y8,        ,8P    #
#       88            Y8a.    .a8P       88      .a8P        Y8a.    .a8P     #
#       88             `"Y8888Y"'        88888888Y"'          `"Y8888Y"'      #
#                                                                             #
"""############################################################################

Features:
---------
? specify download destination
X what file within assets?
- whether to unpack/unzip etc



"""############################################################################
# URL
#-----------------------
# user/repo-name/releases[/latest]
URL_BASE = 'https://api.github.com/repos/{}/{}/releases{}'

# parser for user/repo
#-----------------------
parser = argparse.ArgumentParser()
parser.add_argument('--user',        '-u', type=str, required=True)
parser.add_argument('--repo',        '-r', type=str, required=True)
parser.add_argument('--ext',         '-x', type=str, default='zip', )#choices=['zip', 'deb', 'AppImage', 'apk', 'pdf'])
parser.add_argument('--pre_release', '-p', action="store_true")


def query_user(urls):
    N = len(urls)
    print('\nPlease select which file to download:')
    print('-------------------------------------')
    for i, u in enumerate(urls, start=1):
        if len(u) > 80:
            u = u.split('/')[-1]
        print(f'  {i:>2}: {u}')

    max_tries = 4
    valid_nums = list(range(1, N+1))
    msg_ask = 'URL num: '
    while max_tries:
        usr_choice = input(msg_ask)
        if usr_choice.isdecimal() and 1 <= eval(usr_choice) <= N:
            return eval(usr_choice) - 1
        #input('Please select a valid number: ')
        msg_ask = 'Please select a valid number: '
        max_tries -= 1
    print('No valid selections, exiting')
    sys.exit()

check_ext = lambda a, x: a['name'].endswith(x)


def get_urls(json, ext):
    dl_urls = []
    for asset in json['assets']:
        if check_ext(asset, ext):
            dl_urls.append(asset['browser_download_url'])
    return dl_urls

def download(urls):
    n = len(urls)
    if n == 0:
        print(f'Unable to find any matching download url with extension')
        return
    if n == 1:
        url = urls.pop()
    else:
        idx = query_user(urls)
        url = urls[idx]
    sname = url.split('/')[-1]
    print(f'Downloading {sname}')
    urlretrieve(url, sname)


if __name__ == '__main__':
    # Get url fields
    #-----------------------
    parsed = parser.parse_args()
    user, repo = parsed.user, parsed.repo
    ext = '.' + parsed.ext
    pre_release = parsed.pre_release
    release_level = '' if pre_release else '/latest'
    URL = URL_BASE.format(user, repo, release_level)

    # function kwarg
    #-------------------
    headers = {'Accept': 'application/vnd.github.v3+json'}

    # GET
    #-------------------
    try:
        json = loads(urlopen(Request(URL, headers=headers)).read())
    except:
        raise ValueError('Unsuccessful request')
        sys.exit()
    print('Successful request, now searching assets for release url')
    urls = get_urls(json, ext)
    download(urls)
