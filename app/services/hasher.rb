# frozen_string_literal: true

module Hasher
  def self.perform(value)
    Digest::SHA2.hexdigest(value.to_s + Secrets.salt)
  end
end
