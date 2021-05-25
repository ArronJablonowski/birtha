echo " "
echo "HOURLY CRONS"
echo "************"
ls -la /etc/cron.hourly/

echo " "
echo "DAILY CRONS"
echo "***********"
ls -la /etc/cron.daily/

echo " "
echo "WEEKLY CRONS"
echo "************"
ls -la /etc/cron.weekly/

echo " "
echo "Monthly CRONS"
echo "*************"
ls -la /etc/cron.monthly/

echo " "
echo "CRON TAB"
echo "********"
cat /etc/crontab
