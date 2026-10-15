{{
config(
    materialized='incremental',
    unique_key='comment_id'
)
}}
with sil_comments as (
    select *
    from {{ ref('src_airport_comments') }}
)
select 
    comment_id,
    airport_ident,
    comment_timestamp,
    case 
        when member_nickname is null then '__UNKNOWN__' 
            else member_nickname 
        end as
    member_nickname,
    comment_subject,
    comment_body,
    CURRENT_TIMESTAMP() as loaded_at
from sil_comments
where comment_body is not null
{% if is_incremental() %}
    and comment_id > (select max(comment_id) from {{ this }})
{% endif %}