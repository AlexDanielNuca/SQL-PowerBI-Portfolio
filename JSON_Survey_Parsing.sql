DROP TABLE IF EXISTS survey_responses;

CREATE TABLE survey_responses (
    response_id SERIAL PRIMARY KEY,
    response_data JSONB
);

INSERT INTO survey_responses (response_data) VALUES 
('{"marketing_channel": "Google Search", "age": 57, "nps_score": 9, "comment": "Not satisfied."}'),
('{"marketing_channel": "TikTok", "age": 64, "nps_score": 9, "comment": "Too expensive."}'),
('{"marketing_channel": "Facebook", "age": 28, "nps_score": 10, "comment": null}'),
('{"marketing_channel": "Facebook", "age": 46, "nps_score": 7, "comment": "Will buy again!"}'),
('{"marketing_channel": "Instagram", "age": 40, "nps_score": 1, "comment": null}'),
('{"marketing_channel": "Facebook", "age": 20, "nps_score": 5, "comment": null}'),
('{"marketing_channel": "Instagram", "age": 18, "nps_score": 8, "comment": "Product broke after 2 days."}'),
('{"marketing_channel": "Instagram", "age": 20, "nps_score": 5, "comment": null}'),
('{"marketing_channel": "Instagram", "age": 22, "nps_score": 7, "comment": "Loved the delivery speed."}'),
('{"marketing_channel": "Instagram", "age": 53, "nps_score": 9, "comment": "Will buy again!"}'),
('{"marketing_channel": "Facebook", "age": 20, "nps_score": 6, "comment": "Will buy again!"}'),
('{"marketing_channel": "Instagram", "age": 60, "nps_score": 10, "comment": null}'),
('{"marketing_channel": "Google Search", "age": 63, "nps_score": 5, "comment": null}'),
('{"marketing_channel": "Google Search", "age": 27, "nps_score": 1, "comment": "Too expensive."}'),
('{"marketing_channel": "Email", "age": 36, "nps_score": 6, "comment": null}'),
('{"marketing_channel": "Instagram", "age": 38, "nps_score": 4, "comment": null}'),
('{"marketing_channel": "TikTok", "age": 54, "nps_score": 4, "comment": null}'),
('{"marketing_channel": "Facebook", "age": 51, "nps_score": 10, "comment": null}'),
('{"marketing_channel": "Email", "age": 49, "nps_score": 9, "comment": "Not satisfied."}'),
('{"marketing_channel": "TikTok", "age": 46, "nps_score": 9, "comment": "Great service!"}');

select 
	response_id,
	response_data ->> 'marketing_channel' as channel,
	(response_data ->> 'age'):: INTEGER as age,
	(response_data ->> 'nps_score'):: INTEGER as nps_score 
from survey_responses
limit 5;

select 
	response_data ->> 'marketing_channel' as channel,
	COUNT(*) as total_responses,
	ROUND(AVG((response_data ->> 'nps_score'):: INTEGER),2) as avg_nps_score
from survey_responses
group by 1
order by avg_nps_score DESC;

select 
	response_data ->> 'marketing_channel' as channel,
	(response_data ->> 'nps_score'):: INTEGER as score,
	response_data ->> 'comment' as customer_comment
from survey_responses
where  response_data ->> 'comment' is not null 
order by score desc;