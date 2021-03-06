truncate table temp_20180222_02;
drop table temp_20180222_02;
create table temp_20180222_02 as 
select b.c_proj_code as c_grain,b.c_proj_name ,round(sum(a.f_balance_agg)/10000,2) as f_value
  from dataedw.tt_tc_scale_cont_m   a,
       dataedw.dim_tc_contract      d,
       dataedw.dim_pb_project_basic b,
       dataedw.dim_pb_project_biz   c,
       dataedw.dim_pb_product       e
 where a.l_proj_id = b.l_proj_id
   and d.l_prod_id = e.l_prod_id
   and a.l_cont_id = d.l_cont_id
   and b.l_proj_id = c.l_proj_id
   and substr(d.l_effective_date, 1, 6) <= a.l_month_id
   and substr(d.l_expiration_date, 1, 6) > a.l_month_id
   and a.l_month_id = 201802
 group by b.c_proj_code,b.c_proj_name;

truncate table temp_20180222_04;
drop table temp_20180222_04;
create table temp_20180222_04 as 
select t3.c_proj_code,
       t3.c_proj_name ,
       round(nvl(sum(case when t1.c_ietype_code_l1 = 'XTSR' then  t.f_planned_agg else 0 end),0)/10000,2) as f_xtsr,--合同收入
       round(nvl(sum(decode(t1.c_ietype_code_l2, 'XTBC', t.f_planned_agg, 0)), 0)/10000,2) as f_xtbc, --累计计划信托报酬
       round(nvl(sum(decode(t1.c_ietype_code_l2, 'XTCGF', t.f_planned_agg, 0)), 0)/10000,2) as f_xtcgf --累计计划财顾费
  from dataedw.tt_ic_ie_prod_m      t,
       dataedw.dim_pb_ie_type       t1,
       dataedw.dim_pb_product       t2,
       dataedw.dim_pb_project_basic t3
 where t.l_month_id = 201802
   and t.l_ietype_id = t1.l_ietype_id
   and t.l_prod_id = t2.l_prod_id
   and t2.l_proj_id = t3.l_proj_id
   and substr(t2.l_effective_date, 1, 6) <= t.l_month_id
   and substr(t2.l_expiration_date, 1, 6) > t.l_month_id
   and (t3.l_expiry_date > 20180231 or t3.l_expiry_date is null)
 group by t3.c_proj_code, t3.c_proj_name;

truncate table temp_20180222_06;
drop table temp_20180222_06;
create table temp_20180222_06 as 
select a.c_proj_code,
a.c_proj_name,
       round(sum(t.f_decrease_agg) / 10000,2) as f_qsgm
  from dataedw.tt_tc_scale_cont_m   t,
       dataedw.dim_tc_contract      x,
       dataedw.dim_pb_product       y,
       dataedw.dim_pb_project_basic a,
       dataedw.dim_pb_project_biz   b
 where t.l_cont_id = x.l_cont_id
   and x.l_prod_id = y.l_prod_id
   and y.l_proj_id = a.l_proj_id
   and a.l_proj_id = b.l_proj_id
   and t.l_month_id = 201802
   and substr(y.l_effective_date, 1, 6) <= t.l_month_id
   and substr(y.l_expiration_date, 1, 6) > t.l_month_id
   and substr(a.l_expiry_date, 1, 4) = substr(t.l_month_id,1,4) and substr(a.l_expiry_date, 1, 6) <= t.l_month_id
 group by a.c_proj_code,a.c_proj_name ;
 
truncate table temp_20180222_08;
drop table temp_20180222_08;
create table temp_20180222_08 as 
select t1.c_object_code as c_proj_code
  from dataedw.tt_pb_object_status_m t1, dataedw.dim_pb_object_status t2
 where t1.l_month_id = 201802
   and t1.l_objstatus_id = t2.l_objstatus_id
   and t1.c_object_type = 'XM'
   and t2.l_setup_ty_flag = 1 /*and t1.l_object_id = 3308*/;

select * from dataedw.dim_pb_project_basic t where t.c_proj_code = 'AVICTC2017X0860';
select * from dataedw.tt_pb_object_status_m t where t.l_object_id = 3308 and t.c_object_type = 'XM';
select * from dataedw.dim_pb_object_status t where t.l_objstatus_id = 20;

truncate table temp_20180222_10;
drop table temp_20180222_10;
create table temp_20180222_10 as    
select a17.c_proj_code,a17.c_proj_name, round(sum(a11.F_BALANCE_AGG) / 10000,2) as f_xzgm
  from dataedw.TT_TC_SCALE_CONT_M a11
  join dataedw.DIM_TC_CONTRACT a12
    on (a11.L_CONT_ID = a12.L_CONT_ID)
  join dataedw.DIM_PB_PRODUCT a13
    on (a12.L_PROD_ID = a13.L_PROD_ID)
  join dataedw.DIM_PB_PROJECT_BIZ a15
    on (a13.L_PROJ_ID = a15.L_PROJ_ID)
  join dataedw.DIM_MONTH a16
    on (a11.L_MONTH_ID = a16.MONTH_ID)
  join dataedw.DIM_PB_PROJECT_basic a17
    on (a13.L_PROJ_ID = a17.L_PROJ_ID)
 where (SUBSTR(a13.L_EFFECTIVE_DATE, 1, 6) <= a11.L_MONTH_ID and
       SUBSTR(a13.L_EXPIRATION_DATE, 1, 6) > a11.L_MONTH_ID and
       a16.MONTH_DATE = trunc(To_Date('31-12-2017', 'dd-mm-yyyy'), 'mm') and
       a15.L_POOL_FLAG = 0 and substr(a13.L_SETUP_DATE, 1, 4) = '2018')
 group by a17.c_proj_code,a17.c_proj_name;

--存续项目个数/规模，按功能分类
truncate table temp_20180222_12;
drop table temp_20180222_12;
create table temp_20180222_12 as  
select  e.c_proj_code,e.c_proj_name,count(*) as f_gs
  from dataedw.dim_pb_project_biz    b,
       dataedw.dim_pb_object_status  c,
       dataedw.tt_pb_object_status_m d,
       dataedw.dim_pb_project_basic  e
 where b.l_proj_id = d.l_object_id
   and d.c_object_type = 'XM'
   and c.l_objstatus_id = d.l_objstatus_id
   and c.l_exist_tm_flag = 1
   and b.l_proj_id = e.l_proj_id
   and d.l_month_id = 201802
   and (e.l_expiry_date > 20180228 or e.l_expiry_date is null)
   and substr(e.l_effective_date, 1, 6) <= d.l_month_id
   and substr(e.l_expiration_date, 1, 6) > d.l_month_id group by e.c_proj_code,e.c_proj_name;
