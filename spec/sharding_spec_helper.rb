#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/support/onceler/sharding')

unless defined?(Switchman::RSpecHelper)
  module ShardRSpecHelper
    def self.included(klass)
      klass.before do
        skip "needs a sharding implementation"
      end
      require File.expand_path(File.dirname(__FILE__) + '/support/onceler/noop') unless defined?(Onceler::Noop)
      klass.send(:include, Onceler::Noop)
    end
  end

  RSpec.configure do |config|
    config.before :all do
      Shard.default.destroy if Shard.default.is_a?(Shard)
      Shard.default(true)
    end
  end

  def specs_require_sharding
    include ShardRSpecHelper
  end
else
  def specs_require_sharding
    include Switchman::RSpecHelper
    include Onceler::Sharding

    before :all do
      Shard.with_each_shard do
        Role.ensure_built_in_roles!
      end
    end
  end
end
