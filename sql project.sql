/* create table */

create table ipl_ball (id int,innings int,over int,ball int,batsman varchar,
					   no_striker varchar,bowler varchar,batsman_runs int,
					   extra_runs int,total_runs int,is_wicket int,dismissal_kind varchar,
					   player_dismissed varchar,fielder varchar,
					   extras_type varchar,batting_team varchar,bowling_team varchar);
					   
copy ipl_ball from 'C:\Program Files\PostgreSQL\15\data\IPL_Ball\IPL_ball.csv' delimiter',' csv header;					   
					   
	select * from ipl_ball;		
	
/* create table */

create table ipl_match (id int,city int,player_match varchar,venue varchar,neutal_venue varchar,
					    team1 varchar(817),team2 varchar(817),toss_winner varchar,winner varchar,runs int,result varchar,
					    result_margin varchar,eliminator varchar,method int,umpire_1 varchar,umpire_2 varchar);
						
copy ipl_match from 'C:\Program Files\PostgreSQL\15\data\IPL_match\IPL_match.csv' delimiter',' csv header;					
	
	select * from ipl_match;
	
	select batsman as playername,
	sum(batsman_runs) as totalruns,
	count(ball) as ballsfaced,
	sum(batsman_runs) /count(ball) as
 strikerate							
	from ipl_ball
	where batsman_runs > 0
	group by batsman
	having count(ball) >=500
	order by strikerate desc
	limit 3;
	
	select batsman as playername,
	avg(batsman_runs) as averageruns,
	count(DISTINCT batting_team) as
	seasonsplayed
	from ipl_ball
	where batsman_runs >0
	group by batsman
	having count(distinct batting_team) > 2
	order by averageruns desc
	limit 3;
	
	select batsman, sum(batsman_runs) as 
	total_runs
	from ipl_ball
	where is_wicket = 0
	group by batsman
	order by total_runs desc
	limit 3;
	
	select bowler,
	       sum(batsman_runs) as 
	total_runs_given,
	       count(*) as total_balls_bowled, 
           sum(batsman_runs) / (count(*) /
	6) as economy							
	from ipl_ball
	group by bowler
	having count(*) >=500
	order by economy
	limit 3;
	
	
	select bowler,
	       count(*) as total_balls_bowled,
		   sum(is_wicket) as total_wickets,
		   (count(*) * 6)  / sum(is_wicket)
	as strike_rate
	from ipl_ball
	group by bowler
	having count(*) >= 500
	order by strike_rate
	limit 3;
	
	select all_rounder_batsman,
	       sum(batsman_runs) as 
	total_runs_scored,
	        count(*) as balls_faced,
			count(distinct baller_id) as
	balls_bowled,
	        sum(case when dismissal_kind <>
			   'not out' then 1 else 0 end) as
			   total_wickets_taken,
			   (count(*) * 6) / sum(case when 
				dismissal_kind <> 'not out' then 1 else 0 end)
				as batting_strike_rate,
	       (count(distinct baller_id) * 6) /
		   count(distinct baller_id) as
		   bowling_strike_rate
		   from(
			   select batsman as all_rounder_batsman, id,
			   batsman_runs, dismissal_kind
			   from ipl_ball
			   where batsman_runs > 0
			   group by batsman,id,batsman_runs,
			   dismissal_kind
			   having count(*) >=500
			   ) as batsmen
		inner join (
		     select bowler as all_rounder_bowler, id as baller_id
		     from ipl_ball
		     group by bowler, id
		     having count(*) >= 300
		) as bowlers on batsmen.all_rounder_batsman =
		 bowlers.all_rounder_bowler
		group by all_rounder_batsman
		order by batting_strike_rate,
		bowling_strike_rate
		limit 3;
	
	select 'player name' as player, 'total
	runs' as runs -- header row
	union all
	select cast(batsman as varchar) as 
	player, cast(sum(batsman_runs) as 
	varchar) as runs
	from ipl_ball
	where is_wicket = 0
	group by batsman
	order by sum(batsman_runs) desc
	limit 3;
	
	/*additional questions */
	
	1.select count(distinct city) as totalcitieshostedIPL
	from ipl_match;
	
	2. create table deliveries_v02 as
	select *,
	case
	   when total_runs >=4 then
	'boundary'
	  when total_runs =0 then 'dot'
	  else 'other'
	  END AS ball_result
	from deliveries;  
	
	3. select
	       ball_result,
		   count(*) as total_count
		 from deliveries_v02
		 where ball_result IN ('boundary','dot')
		 group by ball_result;
		 
	4.select batting_team,
	    count(*) AS total_boundaries
	from deliveries_v02
	where ball_result = 'boundary'
	group by batting_team
	order by total_boundaries desc;
	
	5.select bowling_team,
	     count(*) as total_dot_balls
		from deliveries_v02
		where ball_result = 'dot'
	group by bowling_team
	order by total_dot_balls;
	
	6. select dismissal_kind,
	     count(*) AS total_dismissals
		from ipl_ball
		where dismissal_kind IS NOT NULL AND
		dismissal_kind !='NA'
		GROUP BY dismissal_kind;

   7. select bowler, SUM(extra_runs) AS
     total_extra_runs
	 from ipl_match
	 full join ipl_ball ON ipl_match.id =
	 ipl_ball.id
	 group by bowler
	 order by SUM(extra_runs) desc
	 limit 5;
	 
	8. create table deliveries_v03 as
	   select dv.*, m.venue, m.match_date
	   from deliveries_v02 dv
	   join matches m on dv.match_id =
	   m.id;
	   
	 9.select venue, sum(runs) as total_runs
	 from ipl_match
	 group by venue
	 order by total_runs desc;
	 
	 10.select EXTRACT(YEAR FROM match_date) AS
	 match_year, sum(runs) as total_runs
	 from ipl_match
	 where venue = 'Eden Gardens'
	 group by EXTRACT (YEAR FROM match_date)
	 order by total_runs desc;