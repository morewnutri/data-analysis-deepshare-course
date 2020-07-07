use project1;
select * from project1 limit 10;

1）从智能产品的角度

1.1 热度最高的产品（Excel）

以被评论数来测量产品热度

select id,name,avg(`reviews.rating`),count(`reviews.text`),count(id)
from project1
group by id,name
order by count(`reviews.rating`) desc
limit 10;
#conclusion:热度最高的产品为fire tablet，Kindle，echo

1.2 品牌总体评价

以品牌分类，计算出的平均评分为品牌评价标准

select brand,avg(`reviews.rating`) as avg_rating
from project1
group by brand
order by avg_rating;
#amazon fire tv 4.7,amazon 4.5,amazon fire 4.5

1.3 类别的总体情况

select categories,avg(`reviews.rating`) as avg_rating
from project1 
group by categories
order by avg_rating desc;
#fire tablets 5,electronics 5

1.4 厂家和评价的关系（查看Excel）

select manufacturer,avg(`reviews.rating`) as avg_rating
from project1
group by manufacturer
order by avg_rating desc;
#用sql查看时厂家只有一个，用Excel查看有两个 -->sql数据导入不全，数据缺失

1.5 密钥的复杂程度是否影响评价

先求得密钥的平均长度，以平均长度以下的为简单密钥，平均长度以上的密钥为复杂密钥
分别计算对应的平均评分

select distinct(`keys`) from project1;
select avg(length(`keys`) ) from project1;
#420以上的为复杂的密钥，420以下的为简单的密钥

select `keys`as simple_keys,avg(`reviews.rating`) as avg_rating
from project1 where length(`keys`) < 420;

select `keys` as compli_keys,avg(`reviews.rating`) as avg_rating
from project1 where length(`keys`) >= 420;


#根据结果来看密钥长的产品的评分比密钥短的产品的评分略高，用Excel做回归发现密钥与评分无关联。

1.6 从评论数的角度看产品人气，话题度等(无法计算空值，出错）

select sum((case when `reviews.didpurchase` is null then 1 else 0 end)) as `null`,
sum((case when `reviews.didpurchase` is not null then 1 else 0 end)) as not_null
from project1;
#null=0,not_null=34128,实际上只有一个非null

1.7 用户喜欢的产品有什么共性（看Excel）


2. 从用户的角度切入

2.1 用户产品偏好

2.2 用户关注智能产品那些点

2.3 用户普遍喜欢哪些产品特点，讨厌哪些特点

2.4 用户评论最活跃的时间点（看Excel）

2.5 给客户打上标签

2.6 用户品牌偏好（Excel也有）

对某个品牌的评论数多少来测定用户品牌偏好

select brand,categories,count(`reviews.rating`)
from project1
group by brand,categories
order by count(`reviews.rating`);

2.7 用户类别偏好

根据用户评论数和评分测用户偏好

select brand,avg(`reviews.rating`),count(`reviews.rating`)
from project1
group by brand
order by avg(`reviews.rating`) desc;

2.8 用户偏好生产厂家(excel)

根据用户评论数和评分测厂家偏好

select manufacturer,avg(`reviews.rating`),count(`reviews.rating`)
from project1
group by manufacturer
order by avg(`reviews.rating`) desc;



2.9 用户偏好的特定产品

根据用户评论数和评分测产品偏好,用户对某个特定产品的评论数决定偏好

select `reviews.username`,categories,avg(`reviews.rating`),count(`reviews.rating`)
from project1
group by `reviews.username`,categories
order by count(`reviews.rating`) desc;

2.10 密钥复杂是否会被评论（Excel回归分析）

select distinct(`keys`) from project1;
select avg(length(`keys`) ) from project1;
#平均长度为420以上的为复杂的密钥，420以下的为简单的密钥

2.11 这个人是不是很难取悦

用户平均评分来测评

select `reviews.username`,avg(`reviews.rating`)
from project1
group by `reviews.username`
order by avg(`reviews.rating`) asc;

2.12 这个人是不是爱评论（看Excel）

用评论数和评论字数评定

2.13 这个人是不是长时间活跃（Excel） 

累加用户发表评论的天数

可以看出爱评论的人和长时间活跃的人高度重叠，可能是宅男，孤独的人。

2.14 这个人是不是喜欢四处走

数据缺失无法计算

2.15 这个人总体而言是正向居多还是负向居多

看用户给产品的平均评分来看

select `reviews.username`,avg(`reviews.rating`)
from project1
group by `reviews.username`
order by avg(`reviews.rating`) desc;

2.16 这个人发表看法喜欢讲哪些主题

2.17 用户关注点

如果用户评论里有下列关键词则加1，并计算下裂关键词在所有评论里所占的比例。
price，expensive，quality，size,gift,fast,gift

select `name`,categories,
sum( case when `reviews.text` like '%price%' or '%cheap%' '%expensive%' then 1 else 0 end) as price_view,
sum( case when `reviews.text` like '%price%' or '%cheap%' '%expensive%' then 1 else 0 end)/count(id) as price_percentage,
sum( case when `reviews.text` like '%easy%' or '%difficult%' then 1 else 0 end) as easy_view,
sum( case when `reviews.text` like '%easy%' or '%difficult%' then 1 else 0 end)/count(id) as easy_percentage,
sum( case when `reviews.text` like '%gift%' then 1 else 0 end) as gift_view,
sum( case when `reviews.text` like '%gift%' then 1 else 0 end)/count(id) as gift_percentage,
sum( case when `reviews.text` like '%quality%' then 1 else 0 end) as quality_view,
sum( case when `reviews.text` like '%quality%' then 1 else 0 end)/count(id) as quality_percentage
from project1
group by `name`,categories
order by price_view desc;



