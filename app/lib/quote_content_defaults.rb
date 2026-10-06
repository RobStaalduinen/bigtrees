# frozen_string_literal: true

# The stock "Before we start" and "Terms and conditions" copy, used to seed an
# organization's editable version and as the fallback for any organization that
# has not customised them.
#
# Stored as paragraphs with the clause numbers written literally rather than as
# <ol>/<li>. The content is edited in a contenteditable box, where list
# semantics are easy to mangle and hard to recover — flat paragraphs survive
# arbitrary editing, and the original numbering (terms skip 3, which has never
# existed) is preserved as plain text instead of being silently renumbered.
#
# [ORGANIZATION_NAME] is substituted at render time, matching the macro
# convention the email templates already use, so a rename flows through to
# organizations that have not edited their copy.
module QuoteContentDefaults
  # Literal UTF-8 throughout rather than HTML entities: the editor is a
  # contenteditable box, so anything a user edits comes back as literal
  # characters. Keeping the defaults in the same form means stock and edited
  # copy are represented identically. (The PDF layout declares a charset, so
  # literal characters render correctly — see layouts/pdf.html.erb.)
  ORGANIZATION_MACRO = '[ORGANIZATION_NAME]'

  PRE_JOB = <<~HTML.freeze
    <p>Before we begin, there are a few important things that you should know.</p>
    <p><b>1.</b> We've done this thousands of times. Don't feel you need to schedule a day off the day we do your work. We don't collect payment until the work is done and we don't expect payment the same day.</p>
    <p><b>2.</b> Please make sure the route (ie. driveway, path, yard) to the tree is clear so we can remove the branches.</p>
    <p><b>3.</b> Anything of value (ie. statues, pots, birdfeeders, lights, furniture, bbq's) are moved from the tree. Please notify us of anything you couldn't move. Also, if you have sprinkler systems or septic tanks, we need to know before we start.</p>
    <p><b>4.</b> Please notify your neighbours of the work. Feel free to give them our number in case they have any questions. Have them reference your name and address.</p>
    <p><b>5.</b> We cannot do a thorough cleanup of the small branches if the lawn is unkempt (ie. long, weeds, dog droppings).</p>
    <p><b>6.</b> Our work is physically demanding both on our bodies and equipment. Breakdowns and delays do occur from time to time. Please keep that in mind when it comes to scheduling. Often times we are running a little behind. Also, the weather plays a huge role in whether or not we can work but we do our best to keep you updated as our week progresses.</p>
    <p><b>7.</b> If an existing customer has called in an emergency for tree work, whether from a natural disaster such as severe weather conditions or an unexpected accident, emergency situations and customers take priority. We will revise our plans and schedules to accommodate the needs and priorities of our existing clients and emergency situations.</p>
    <p><b>8. Delays: weather, equipment malfunction, employee injury/illness.</b> Unsafe weather conditions can affect our job (rain, snow, wind, natural disasters) which can make it dangerous to work. Equipment malfunction can occur from time to time. We are constantly maintaining our equipment, but if a piece of machinery is not working properly or is down, it can make it unsafe to perform our job properly. Employee injury/illness: if an employee is unable to attend work due to one of these circumstances, it may make it unsafe to perform our job while shorthanded. We will delay/reschedule any work due to these circumstances as we see fit.</p>
  HTML

  TERMS = <<~HTML.freeze
    <p>Each party agrees to the following terms and conditions.</p>
    <p><b>1. (Completion)</b> — [ORGANIZATION_NAME] agrees to perform the Services set forth in this Contract in a proper and expeditious manner. The Services shall not commence until the Commencement Date, and shall be completed by the Completion Date.</p>
    <p><b>2. (Laws and Regulations)</b> — Each party shall comply with all applicable codes, laws, rules and regulations of federal, state or local authorities as they affect the Services and shall be responsible for any and all damages incurred resulting from their respective failure to comply with said codes, laws, rules and regulations. Each party shall procure at its expense all permits and licenses which may be required to perform its portion of the Services.</p>
    <p><b>4. (DAMAGES)</b> — [ORGANIZATION_NAME] SHALL BE RESPONSIBLE FOR ANY AND ALL INJURY OR DAMAGE TO ANY PERSONS AND/OR PROPERTY, INCLUDING LOSS OF LIFE, ARISING DIRECTLY OR INDIRECTLY FROM OR IN CONNECTION WITH SERVICES PERFORMED UNDER THIS CONTRACT, AND SHALL INDEMNIFY AND HOLD THE OTHER HARMLESS FROM ANY AND ALL LOSS, DAMAGE OR EXPENSE (INCLUDING ATTORNEYS' FEES) FROM ANY SUCH INJURY, DAMAGE, OR DEATH, EXCEPT AS SUCH MAY BE DUE TO THE NEGLIGENCE OF THE OTHER PARTY.</p>
    <p><b>5. (Acts of God)</b> — [ORGANIZATION_NAME] shall not be responsible for any loss or damage to the work (including to materials used, or to be used) caused by fire, lightning, explosion, vehicles, smoke, hail, aircraft, windstorm, flood, earthquake, or other acts of the elements, excepting therefrom any such loss or damage to materials under [ORGANIZATION_NAME] control.</p>
    <p><b>6. (Insurance)</b> — [ORGANIZATION_NAME] agrees to maintain such insurance as will fully protect it from claims under worker's compensation acts; from claims for damages because of bodily injury, including personal injury, sickness or disease, or death, of any of its employees or any other person; and from claims for damages because of injury to or destruction of tangible property, including loss of use resulting therefrom. Limits of coverage for bodily injury and property damage liability shall be $2,000,000.00 per occurrence. Each party shall also purchase and maintain insurance for its own equipment, materials and other personal property to the full insurable value thereof.</p>
    <p><b>7. (Termination)</b> [ORGANIZATION_NAME] may terminate this Contract by giving notice of same at any time without cause. This Contract may be terminated by Customer upon giving at least thirty (30) days' written notice to [ORGANIZATION_NAME] upon the repeated and substantial failure of [ORGANIZATION_NAME] to perform in accordance with all the terms herein, provided that failure to perform is through no fault of Customer. Customer agrees to pay to [ORGANIZATION_NAME] the reasonable value of the Services performed to the date of termination.</p>
    <p><b>8. (Services Rendered)</b> — Upon completion of all Services set forth in the Contract, [ORGANIZATION_NAME] shall submit to Customer one invoice covering such Services, together with such other documentation as Customer shall reasonably request. Customer shall make payment within fourteen (14) days of the date the invoice is received. Payment by Customer shall constitute a waiver of all claims by Customer.</p>
    <p><b>9. (Payment Terms)</b> — Net Payment is due 30 days from invoice date. Late Fees will be subjected to a 30% payment increase after 30 days and be sent to collections if no prior arrangements have been made.</p>
  HTML

  # The only tags the editor produces and the only ones the PDF will render.
  # Everything else is stripped on the way out, so pasted markup from a word
  # processor cannot reach the document.
  ALLOWED_TAGS = %w[p br b strong i em u div].freeze

  def self.for(key)
    case key.to_sym
    when :pre_job then PRE_JOB
    when :terms   then TERMS
    else raise ArgumentError, "unknown quote content key: #{key}"
    end
  end
end
