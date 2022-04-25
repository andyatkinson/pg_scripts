---https://dba.stackexchange.com/a/39758
select * 
from pg_stat_activity
where (state = 'idle in transaction')
    and xact_start is not null;
