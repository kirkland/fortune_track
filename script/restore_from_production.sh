#!/bin/bash

log='log/restore_from_production.log'
err='log/restore_from_production_error.log'
echo 'Starting restore' > $log
echo 'Starting restore' > $err

if [[ ! -f fortune_track_production.sql ]]; then
  echo 'Put fortune_track_production.sql in root of project first.'
  exit 1
else
  echo 'Restoring from fortune_track_production.sql'
fi

bundle exec rake db:drop > $log 2>$err
if [[ $? != 0 ]]; then
  echo 'Problem dropping database.'
  echo "See $log and $err for details."
  exit 1
fi

bundle exec rake db:create > $log 2>$err
if [[ $? != 0 ]]; then
  echo 'Problem creating database.'
  echo "See $log and $err for details."
  exit 1
fi

psql -U postgres -d fortune_track_development -f fortune_track_production.sql > $log 2>$err
grep ERROR $err > /dev/null
if [[ $? == 0 ]]; then
  echo 'Problem restoring database.'
  echo "See $log and $err for details."
  exit 1
else
  echo 'Done.'
fi
