RSpec::Support.require_rspec_core "formatters/console_codes"

RSpec.configure do |config|
  def expect_failure
    pending 'example expected failure'
  end
end

# Based on https://stackoverflow.com/a/41869742/226431
module FormatterOverrides
  def example_pending(pending)
    # this breaks the ability to _actually_ pend an example, and doesn't
    # properly count examples in final tally

    output.puts passed_output(pending.example)

    flush_messages
  end

  def dump_pending(_)
    # NOOP
  end
end

RSpec::Core::Formatters::DocumentationFormatter.prepend FormatterOverrides
