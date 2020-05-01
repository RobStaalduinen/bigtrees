$("#payout-data").html("<%= escape_javascript(render partial: 'payouts/partials/payout_display', locals: { work_records: @work_records } ) %>"); 
