#!/usr/bin/env bash
cd /var/www/apps/enotis/current
RAILS_ENV=production /var/www/apps/enotis/current/bin/delayed_job --pid-dir=/var/www/apps/enotis/shared/pids/ stop