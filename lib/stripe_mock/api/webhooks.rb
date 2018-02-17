module StripeMock

  def self.mock_webhook_payload(type, params = {})

    fixture_file = File.join(@webhook_fixture_path, "#{type}.json")

    unless File.exists?(fixture_file)
      unless Webhooks.event_list.include?(type)
        raise UnsupportedRequestError.new "Unsupported webhook event `#{type}` (Searched in #{@webhook_fixture_path})"
      end
      fixture_file = File.join(@webhook_fixture_fallback_path, "#{type}.json")
    end

    json = MultiJson.load  File.read(fixture_file)

    json = Stripe::Util.symbolize_names(json)
    params = Stripe::Util.symbolize_names(params)
    json[:account] = params.delete(:account) if params.key?(:account)
    json[:data][:object] = Util.rmerge(json[:data][:object], params)
    json.delete(:id)
    json[:created] = params[:created] || Time.now.to_i

    if @state == 'local'
      event_data = instance.generate_webhook_event(json)
    elsif @state == 'remote'
      event_data = client.generate_webhook_event(json)
    else
      raise UnstartedStateError
    end
    event_data
  end

  def self.mock_webhook_event(type, params={})
    Stripe::Event.construct_from(mock_webhook_payload(type, params))
  end

  module Webhooks
    def self.event_list
      @__list = [
        'account.application.deauthorized',
        'account.external_account.created',
        'account.external_account.deleted',
        'account.external_account.updated',
        'account.updated',
        'application_fee.created',
        'application_fee.refund.updated',
        'application_fee.refunded',
        'balance.available',
        'charge.captured',
        'charge.dispute.closed',
        'charge.dispute.created',
        'charge.dispute.funds_reinstated',
        'charge.dispute.updated',
        'charge.failed',
        'charge.pending',
        'charge.refund.updated',
        'charge.refunded',
        'charge.succeeded',
        'charge.updated',
        'coupon.created',
        'coupon.deleted',
        'coupon.updated',
        'customer.bank_account.deleted',
        'customer.created',
        'customer.deleted',
        'customer.discount.created',
        'customer.discount.deleted',
        'customer.discount.updated',
        'customer.source.created',
        'customer.source.deleted',
        'customer.source.expiring',
        'customer.source.updated',
        'customer.subscription.created',
        'customer.subscription.deleted',
        'customer.subscription.trial_will_end',
        'customer.subscription.updated',
        'customer.updated',
        'file.created',
        'invoice.created',
        'invoice.payment_failed',
        'invoice.payment_succeeded',
        'invoice.sent',
        'invoice.upcoming',
        'invoice.updated',
        'invoiceitem.created',
        'invoiceitem.deleted',
        'invoiceitem.updated',
        'order_return.created',
        'order.created',
        'order.payment_failed',
        'order.payment_succeeded',
        'order.updated',
        'payout.canceled',
        'payout.created',
        'payout.failed',
        'payout.paid',
        'payout.updated',
        'plan.created',
        'plan.deleted',
        'plan.updated',
        'product.created',
        'product.deleted',
        'product.updated',
        'recipient.created',
        'recipient.deleted',
        'recipient.updated',
        'review.closed',
        'review.opened',
        'sigma.scheduled_query_run.created',
        'sku.created',
        'sku.deleted',
        'sku.updated',
        'source.canceled',
        'source.chargeable',
        'source.failed',
        'source.mandate_notification',
        'source.transaction.created',
        'transfer.created',
        'transfer.reversed',
        'transfer.updated',
      ]
    end
  end

end
