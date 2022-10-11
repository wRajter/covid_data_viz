-- update the date column that is stored as string to datetime in both deaths and vaccination table

UPDATE deaths
SET date = str_to_date(date, "%d/%m/%Y");

UPDATE vaccination
SET date = str_to_date(date, "%d/%m/%Y");