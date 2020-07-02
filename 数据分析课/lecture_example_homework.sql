

select  id,assists,kills,headshotKills,revives,damageDealt from  juediqiusheng where kills>30 ORDER BY damageDealt


#狙击型选手排名
select  id,assists,kills,headshotKills,revives,damageDealt,longestKill 
from  juediqiusheng where longestKill>900 and headshotKills>5 ORDER BY kills DESC
#一般最远狙击距离为800米以上，为了选出狙击型玩家需要对headshot，longestKill进行设定标准，
#选出杀敌最多的玩家

#综合排名
select  id,assists,kills,headshotKills,revives,damageDealt,longestKill
from  juediqiusheng where headshotKills>1 and kills> 10 and revives>1 and assists>3
ORDER BY damageDealt DESC
#headshotKills,kills,revives,assists等指标满足一定条件下根据damagedealt进行排名。
#综合排名得出的玩家复活人数和助攻均大于狙击型玩家，推测输出高的玩家是跟朋友在玩儿，且不喜欢玩儿狙击，
#狙击型玩家复活人数和助攻书都趋于零，可能狙击型玩家喜欢单干。

#输出排名
select  id,assists,kills,headshotKills,revives,damageDealt,longestKill
from  juediqiusheng ORDER BY damageDealt DESC
#从这个排名中可以看出输出与杀敌数成正比，助攻高但是复活人数为零，推测是在游戏中临时组成小团体，同情心较差。

#助攻王
select  id,assists,kills,headshotKills,revives,damageDealt,longestKill
from  juediqiusheng ORDER BY assists DESC

#爆头
select  id,assists,kills,headshotKills,revives,damageDealt,longestKill
from  juediqiusheng ORDER BY headshotKills DESC limit 20
#狙击型选手


04-用sql关联，转置

上一节课的作业

3. 请对每一个字段进行一轮描述性的统计，有多少条记录？最大值最小值是什么？平均值是多少？
总数是多少？存在多少个不重复值？统计完之后请逐一观察这些字段，有没有哪些字段让你感觉异常？
你觉得是为何造成的？又该如何处理？
#此题目的：不能单纯相信官方数据，需要先检查数据质量。
以爆头数这个字段为例，首先统计描述性信息
SELECT
count(*) as row_num,
count(DISTINCT headshotKills) as DISTINCT_headshot,
max(headshotKills) as max_headshot,#函数和括号之间不能有间隔
AVG(headshotKills) as avg_headshot
from juediqiusheng;

4. 借助字段说明你可以知道每个字段的含义，你能不能自己探索一下数据，发现5个有趣的现象？
（例如课程里提到过的马路杀手，杀戮天团，白衣天使都是可能的角度，你能发现更多的角度用数据来揭示更多有趣的现象吗？）
select 
groupid,matchid,
sum(walkdistance) as walkdistance,
sum(swimdistance) as swimdistance,
sum(ridedistance) as ridedistance,
sum(walkdistance+swimdistance+ridedistance) as total_travel_distance
from juediqiusheng
GROUP BY groupid,matchid
ORDER BY total_travel_distance DESC
limit 10;
#结果显示移动距离主要靠载具和走路，想走的远就不能游泳。


5. 请从个人，团队，比赛这三个维度中任选一个维度。基于数据集中的数据构建一套指标评判体系。
如何评判你所选的这个维度（个人，团队或比赛)的优劣？用你的数据评价你所选的维度。
#将杀敌，复活队友，主攻看成三个表现评价角度，设置相应的权重，那么：
SELECT id,matchid,revives,kills,assists,
kills*0.4+revives*0.4+assists*0.2 as performance_index#0.4+0.4+0.2
from juediqiusheng
order by performance_index DESC
limit 10;




 
