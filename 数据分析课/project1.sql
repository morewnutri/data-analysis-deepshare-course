use project1;
select * from project1 limit 10;

1）从智能产品的角度

1.1 热度最高的产品（Excel）

select id,name,avg(`reviews.rating`) as avg_rating,count(id) as frequency
from project1
group by id,name
order by count(id) desc
limit 10;
#when there is column 'name' 10750 5056
#when there is no column 'name' 10964 6607 5056
#conclusion:热度最高的产品为fire tablet，Kindle，echo

1.2 品牌总体评价

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

select distinct(`keys`) from project1;
select avg(length(`keys`) ) from project1;
#420以上的为复杂的密钥，420以下的为简单的密钥

select `keys`as simple_keys,avg(`reviews.rating`) as avg_rating
from project1 where length(`keys`) < 420
group by `keys` 
order by avg_rating;

select `keys` as compli_keys,avg(`reviews.rating`) as avg_rating
from project1 where length(`keys`) >= 420
group by `keys` 
order by avg_rating;

#there is no correlation between keys and rating 

1.6 从评论数的角度看产品人气，话题度等(无法计算空值）

select sum(`reviews.didpurchase`) from project1;

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

2.10 密钥复杂是否会被评论

select distinct(`keys`) from project1;
select avg(length(`keys`) ) from project1;
#平均长度为420以上的为复杂的密钥，420以下的为简单的密钥

select sum((case when `reviews.text` is null then 1 else 0 end)) as `null`,
sum((case when `reviews.text` is not null then 1 else 0 end)) as not_null
from project1;

#不管密钥长度如何都被评论了，评论数与密钥长度无明显关联

select `keys`as simple_keys,count(`reviews.rating`) as num_rating
from project1 where length(`keys`) < 420
group by `keys` 
order by num_rating desc;

select `keys` as compli_keys,count(`reviews.txt`) as num_rating
from project1 where length(`keys`) >= 420
group by `keys` 
order by num_rating desc;

#从结果上看，无明显关联

2.11 这个人是不是很难取悦

用户平均评分来测评

select `reviews.username`,avg(`reviews.rating`)
from project1
group by `reviews.username`
order by avg(`reviews.rating`) asc;

2.12 这个人是不是爱评论（看Excel）

用评论数和评论字数评定

2.13 这个人是不是长时间活跃 

累加用户发表评论的天数

可以看出爱评论的人和长时间活跃的人高度重叠，可能是宅男，孤独的人。

2.14 这个人是不是喜欢四处走

数据确实无法计算

2.15 这个人总体而言是正向居多还是负向居多

select `reviews.username`,avg(`reviews.rating`)
from project1
group by `reviews.username`
order by avg(`reviews.rating`) desc;

2.16 这个人发表看法喜欢讲哪些主题




