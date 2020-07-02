#请对每一个字段进行一轮描述性的统计，有多少条记录？最大值最小值是什么？平均值是多少？总数是多少？
#存在多少个不重复值？统计完之后请逐一观察这些字段，有没有哪些字段让你感觉异常？你觉得是为何造成的？又该如何处理？

SELECT count(*)from juediqiusheng;

SELECT (kills) from juediqiusheng;

#4. 借助字段说明你可以知道每个字段的含义，你能不能自己探索一下数据，发现5个有趣的现象？
#（例如课程里提到过的马路杀手，杀戮天团，白衣天使都是可能的角度，你能发现更多的角度用数据来揭示更多有趣的现象吗？）

select max(walkdistance ) from juediqiusheng;

select a.groupid, 
max(a.headshot)  as  maxheadshot, 
min(a.walkDistance)  as  minwalkdistance 
from (select groupid,matchid, 
sum(headshotKills)  as  headshot, 
sum(walkDistance)  as  walkdistance 
from  juediqiusheng  
group by  groupid,matchId) a 
group by  a.groupid;

select b.groupid,
min(b.walkdistance) as min_walkdistance,
min(b.swimdistance) as min_swimdistance,
min(b.ridedistance) as min_ridedistance,
min(b.kills) as min_kills,
max(b.walkdistance) as max_walkdistance,
max(b.swimdistance) as max_swimdistance,
max(b.ridedistance) as max_ridedistance,
max(b.kills) as max_kills,
AVG(b.walkdistance) as average_walkdistance,
avg(b.swimdistance) as average_swimdistance,
avg(b.ridedistance) as average_ridedistance
from(select groupid,matchid,
sum(walkdistance) as walkdistance,
sum(swimdistance) as swimdistance,
sum(kills) as kills,
sum(ridedistance) as ridedistance
from juediqiusheng
GROUP BY groupid,matchid) b 
group by b.groupid
order by min_walkdistance DESC;
#最大值最小值和平均值都相等，可能是每个队伍只参加了一场比赛，根据步行距离，游泳距离，开车距离
#和杀敌数的关系，大致成高斯分布，跑的少的死的快（死了所以跑的少），一直忙着跑路躲人所以杀敌数少，
#跑路数在中间值的杀敌数比较高。


#5. 请从个人，团队，比赛这三个维度中任选一个维度。基于数据集中的数据构建一套指标评判体系。
#如何评判你所选的这个维度（个人，团队或比赛)的优劣？用你的数据评价你所选的维度。

#个人
select id,
avg(walkdistance) as avg_walkdistance,
avg(swimdistance) as avg_swimdistance,
avg(kills) as avg_kills,
avg(ridedistance) as avg_ridedistance,
avg(assists) as avg_assists,
avg(revives) as avg_revives,
min(walkdistance) as minwalkdistance,
min(swimdistance) as minswimdistance,
min(kills) as minkills,
min(ridedistance) as minridedistance
from juediqiusheng
GROUP BY id
ORDER BY avg_kills desc;
#跑的越多，杀敌数越少，这种人求稳，玩儿游戏的重点在于活到最后的同时淘汰几个人。属于买理财产品时买养老保险之类的。
#杀敌数多的人普遍跑的少，复活人数少，可能单纯的追求淘汰别人的快感，此类人赌徒心理较重，易冲动，
#有可能是资深玩家，知道如何有效躲避追杀的同时淘汰别人。
#（请问代码有什么逻辑错误吗？）

#团队
select groupid,
avg(walkdistance) as avg_walkdistance,
sum(walkdistance) as total_walkdistance,
avg(swimdistance) as avg_swimdistance,
avg(kills) as avg_kills,
avg(ridedistance) as avg_ridedistance,
avg(assists) as avg_assists,
avg(revives) as avg_revives
from juediqiusheng
group by groupid
having avg_kills>=30#where,group by,having,order by同时使用，执行顺序为（1）where过滤数（2）对筛选结果集group by分组（3）对每个分组进行select查询，提取对应的列，有几组就执行几次（4）再进行having筛选每组数据（5）最后整体进行order by排序
ORDER BY avg_kills DESC;#错误出在having语句在order by的后面，having应该在order之前。
#（按团队分类时的总和和平均值相等？）

#比赛
select groupid,matchid,
sum(walkdistance) as walkdistance,
sum(swimdistance) as swimdistance,
sum(kills) as kills,
sum(ridedistance) as ridedistance
from juediqiusheng
GROUP BY groupid,matchid
ORDER BY kills DESC;
#(为什么即使是按groupid,matchid分类，统计的还是个人的数据呢？）


04-sql关联和转置




