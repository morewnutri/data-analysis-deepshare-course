
05-用sql编排截取和自动化脚本课 

3. 请统计一下两家餐厅总销售订单数，总营业额的大小。

create table order_price as 
SELECT a.*,b.`product price`
from orders a
join product b
on a.`item name`=b.`item` and a.`brand_tag`=b.`brand_tag`;

SELECT brand_tag,
count(DISTINCT `order number`) as total_order,
sum(`price`*quantity) as sales
from order_price
group by brand_tag;

4. 哪家餐厅的米饭类比例更高？（米饭类比例=含米饭的订单数/总订单数）

SELECT a.brand_tag,
count(distinct case when a.rice_flag=1 then a.`order number` ELSE
null end)/count(DISTINCT a.`order number`)*100 as rice_rate_1, 
sum(a.rice_flag)/count(a.rice_flag)*100 as rice_rate_2
from(
select brand_tag,`order number`,
max(case when `item name` like '%rice%' then 1 else 0 end) as
rice_flag from order_price
group by brand_tag,`order number`
) a group by a.brand_tag;

5. 请把交易明细表汇总成交易头表，信息包括品牌号，订单编号，时间，总金额，总商品数量，米饭类金额，米饭类数量，咖喱类金额（curry），咖喱类数量，馕类金额，馕类数量。

SELECT `order number`,`order date`,brand_tag,
round(sum(quantity*price),2) as ta,
sum(quantity) as quantity,
sum(case when `item name` like '%naan%' then quantity*price else 0 end) as naan_sales,
sum(case when `item name` like '%rice%' then quantity*price else 0 end) as rice_sales,
sum(case when `item name` like '%naan%' then quantity else 0 end) as naan_quantity,
sum(case when `item name` like '%rice%' then quantity else 0 end) as rice_quantity
from order_price 
GROUP BY `order number`,`order date`,brand_tag



6. 基于第三问的数据，如何看出这三类产品的搭配（只点米饭，米饭+咖喱，米饭+馕等等）情况？两家店的搭配有没有差异？


SELECT rice_flag,curry_flag,naan_flag,
count(DISTINCT case when brand_tag='res_1' then b.`order number` else null end) as res1_transaction,
count(DISTINCT case when brand_tag='res_2' then b.`order number` else null end) as res2_transaction,
count(DISTINCT case when brand_tag='res_1' then b.`order number` else null end)/13397*100 as res1_rate,
count(DISTINCT case when brand_tag='res_2' then b.`order number` else null end)/19558*100 as res1_rate
from(
SELECT a.*,
case when a.rice_quantity>0 then 1 else 0 end as rice_flag,
case when a.curry_quantity>0 then 1 else 0 end as curry_flag,
case when a.naan_quantity>0 then 1 else 0 end as naan_flag
from(
SELECT `order number`,`order date`,brand_tag,
round(sum(quantity*price),2) as ta,
sum(quantity) as quantity,
sum(case when `item name` like '%naan%' then quantity*price else 0 end) as naan_sales,
sum(case when `item name` like '%rice%' then quantity*price else 0 end) as rice_sales,
sum(case when `item name` like '%curry%' then quantity*price else 0 end) as curry_sales,
sum(case when `item name` like '%naan%' then quantity else 0 end) as naan_quantity,
sum(case when `item name` like '%curry%' then quantity else 0 end) as curry_quantity,
sum(case when `item name` like '%rice%' then quantity else 0 end) as rice_quantity
from order_price 
GROUP BY `order number`,`order date`,brand_tag)a)b
GROUP BY rice_flag,curry_flag,naan_flag
order by rice_flag,curry_flag,naan_flag;
从表单可以看出，第一家餐厅点米饭，馕较第二家餐厅多，第二家餐厅点的菜较第一家丰盛，分析得出第一家为屌丝餐厅。

课堂演练 1.concat 函数 
#设置最大编排函数长度
set GLOBAL group_concat_max_len=102400;
set SESSION group_concat_max_len=102400;

create table order_price_concat as 
SELECT `order number`,brand_tag,
GROUP_CONCAT(`item name` order by price desc) as item_set FROM
order_price 
GROUP BY `order number`,brand_tag;

课堂演练 2.数据的截取 

select `order number`,
SUBSTRING_INDEX(item_set,',',2) as top2_high_PriceItems
from order_price_concat;

课堂演练 3.从明细表中选出每笔交易里售价第二高的产品名称(嵌套substring_index来实现)

SELECT `order number`,brand_tag,
SUBSTRING_INDEX(SUBSTRING_INDEX(group_concat(`item name` order by price DESC),',',2),',',-1)
as second_expensive
from order_price 
GROUP BY `order number`,brand_tag;

课堂演练 4.字符串的截取（substr)和拼接(concat)

SELECT *,
CONCAT(substr(`order number`,7,4),'-',substr(`order number`,4,2),'-',substr(`order number`,1,2)) as date 
from order_price;

课堂演练 5.时间函数,

select CURDATE();
SELECT CURTIME();
SELECT NOW();
SELECT SUBDATE(CURDATE(),360);

SELECT MAX(a.`order date`),min(a.`order date`),NOW() as update_time 
from(
SELECT * FROM orders
where `order date` between subdate(CURDATE(),365) and CURDATE()
) a;

课堂演练 5.自动化脚本，用报表功能和批量自动化运行功能来实现每天点购差异的最新情况，最终做到每天自动跑，结果自动发 

			  5.1 建立中间表1，将点法汇总到一列且用文字表示，同时用时间函数筛选最近一年的交易，计算每家店每种点法的具体交易数

create table comparision_daliy_job_1 as
SELECT concat(rice_tag,naan_tag,curry_tag,'') as ordertype,brand_tag,
count(distinct b.`order number`) as transactions
from(
SELECT a.*,
case when a.rice_quantity>0 then 1 else 0 end as rice_flag,
case when a.curry_quantity>0 then 1 else 0 end as curry_flag,
case when a.naan_quantity>0 then 1 else 0 end as naan_flag,
case when a.rice_quantity>0 then 'rice' else '' end as rice_tag,
case when a.curry_quantity>0 then 'curry' else '' end as curry_tag,
case when a.naan_quantity>0 then 'naan' else '' end as naan_tag
from(
SELECT `order number`,`order date`,brand_tag,
round(sum(quantity*price),2) as ta,
sum(quantity) as quantity,
sum(case when `item name` like '%naan%' then quantity*price else 0 end) as naan_sales,
sum(case when `item name` like '%rice%' then quantity*price else 0 end) as rice_sales,
sum(case when `item name` like '%curry%' then quantity*price else 0 end) as curry_sales,
sum(case when `item name` like '%naan%' then quantity else 0 end) as naan_quantity,
sum(case when `item name` like '%curry%' then quantity else 0 end) as curry_quantity,
sum(case when `item name` like '%rice%' then quantity else 0 end) as rice_quantity
from order_price 
GROUP BY `order number`,`order date`,brand_tag
)a
)b
where b.`order date` between subdate(CURDATE(),360) and CURDATE()
GROUP BY CONCAT(rice_tag,naan_tag,curry_tag,''),brand_tag
order by CONCAT(rice_tag,naan_tag,curry_tag,''),brand_tag;
				
				5.2 计算每家店在此次运行中的数据起始日期和总交易数，计入中间表2，为之后关联统计做准备。

create table comparison_daliy_job_2 AS
SELECT brand_tag,count(DISTINCT `order number`) as transactions,max(`order date`) as max_date,min(`order date`) as min_date
from orders
where `order date` between subdate(curdate(),365) and CURDATE()
GROUP BY brand_tag;
				
SELECT* from comparison_daliy_job_2;
				5.3 将中间表1和中间表2关联后汇总计算表1中每种点法的占比，附上每家店此次运行的起始时间并加上本次任务执行完成的时间。
				
SELECT
a.ordertype,
b.min_date as start_time,
b.max_date as end_time,
sum(case when a.brand_tag='res_1' then a.transactions ELSE 0 end) as res1_transaction,
sum(case when a.brand_tag='res_2' then a.transactions ELSE 0 end) as res2_transaction,
round(sum(case when a.brand_tag='res_1' then a.transactions ELSE 0 end)/max(case when a.brand_tag='res_1' then b.transactions else 0 end)*100,1) as res_1_rate,
round(sum(case when a.brand_tag='res_2' then a.transactions ELSE 0 end)/max(case when a.brand_tag='res_2' then b.transactions else 0 end)*100,1) as res_2_rate,
#用Max函数是因为groupby必须要用聚合函数，不然会出错）
NOW() as last_update_time
from comparision_daliy_job_1 a join comparison_daliy_job_2 b on 
a.brand_tag=b.brand_tag
GROUP BY a.ordertype,b.min_date,b.max_date;



















04-用sql关联，转置

#JOIN,将product表里的product price添加到另一个表
create table order_price as
select a.*,b.`product price` as price
from orders a JOIN
product b on a.`item name`=b.`item` and a.brand_tag=b.brand_tag;

#找出两家店共有的菜品
SELECT count(*)
from res1 a join 
res2 b on a.`Item Name`=b.`Item Name`;
#204

#找出res1中独有的菜
SELECT count(*)
from res1 a left join 
res2 b on a.`Item Name`=b.`Item Name`
where b.`Item Name` is null; 
#如果不加where的话的得到的是res1的数据。

#找出res2中独有的菜
SELECT count(*)
from res1 a right join 
res2 b on a.`Item Name`=b.`Item Name`
where a.`Item Name` is null; 


#like,统计每家店各有多少种米饭
select count(DISTINCT `Item` ) as item_count,
brand_tag
from product
where item like '%rice%'
GROUP BY brand_tag;

#case when,分条件引导操作
#找出某个订单中米饭的数量
select `Order Number`,`order date`,brand_tag,
sum(
case when `item name` like '%rice%'
then Quantity
else 0 end) as rice_quantity
from orders
where `order number`=16118 and brand_tag='res_1'
GROUP BY `order number`,`order date`,brand_tag;

#把某个订单16118的囊类花销，饭类花销等统计到一行里。新建的有price的表为order_price
SELECT `order number`,`order date`,brand_tag,
sum(case when `item name` like '%naan%' then quantity*price else 0 end) as naan_amount,
sum(case when `item name` like '%rice%' then quantity*price else 0 end) as rice_amount
from order_price 
where `order number`=16118
GROUP BY `order number`,`order date`,brand_tag



