# frozen_string_literal: true

require 'rubocop'

require 'rubocop/legion'
require 'rubocop/legion/version'
require 'rubocop/legion/plugin'

# Legion/HelperMigration
require 'rubocop/cop/legion/helper_migration/direct_logging'
require 'rubocop/cop/legion/helper_migration/old_logging_methods'
require 'rubocop/cop/legion/helper_migration/direct_json'
require 'rubocop/cop/legion/helper_migration/direct_cache'
require 'rubocop/cop/legion/helper_migration/direct_local_cache'
require 'rubocop/cop/legion/helper_migration/direct_crypt'

# Legion/ConstantSafety
require 'rubocop/cop/legion/constant_safety/bare_data_define'
require 'rubocop/cop/legion/constant_safety/bare_process'
require 'rubocop/cop/legion/constant_safety/bare_json'
require 'rubocop/cop/legion/constant_safety/inherit_param'

# Legion/Singleton
require 'rubocop/cop/legion/singleton/use_instance'

# Legion/RescueLogging
require 'rubocop/cop/legion/rescue_logging/bare_rescue'
require 'rubocop/cop/legion/rescue_logging/no_capture'
require 'rubocop/cop/legion/rescue_logging/silent_capture'

# Legion/Framework
require 'rubocop/cop/legion/framework/eager_sequel_model'
require 'rubocop/cop/legion/framework/sinatra_host_auth'
require 'rubocop/cop/legion/framework/thor_reserved_run'
require 'rubocop/cop/legion/framework/faraday_xml_middleware'
require 'rubocop/cop/legion/framework/module_function_private'
require 'rubocop/cop/legion/framework/cache_time_coercion'
require 'rubocop/cop/legion/framework/api_string_keys'

# Legion/Extension
require 'rubocop/cop/legion/extension/actor_singular_module'
require 'rubocop/cop/legion/extension/core_extend_guard'
require 'rubocop/cop/legion/extension/runner_must_be_module'
require 'rubocop/cop/legion/extension/runner_include_helpers'
require 'rubocop/cop/legion/extension/self_contained_actor_runner_class'
require 'rubocop/cop/legion/extension/runner_return_hash'
require 'rubocop/cop/legion/extension/settings_key_method'
require 'rubocop/cop/legion/extension/settings_bracket_multi_arg'
require 'rubocop/cop/legion/extension/llm_ask_kwargs'
require 'rubocop/cop/legion/extension/data_required_without_migrations'
