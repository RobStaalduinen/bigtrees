module ApplicationHelper

  def javascript_bundle_tag(pack_name)
    if ENV["USE_REMOTE_JS_ASSETS"].present?
      url = build_manifest.dig("bundles", pack_name.to_s)
      raise "No bundle URL for '#{pack_name}' in config/build_manifest.json" if url.blank?
      content_tag(:script, "", src: url, defer: true)
    else
      javascript_pack_tag(pack_name.to_s)
    end
  end

	def is_number string
		true if Float(string) rescue false
	end
	
	def parse_work_action string, info_array
		if string == "Removal"
			return "Tree Removal"
		elsif string == "Broken Limbs"
			return "Broken Limb Removal (" + info_array[0] + ")"
		elsif string == "Trim"
			return "Tree Trimming (" + info_array[0] + ")"
		end
	end

  private

  def build_manifest
    @@manifest ||= JSON.parse(Rails.root.join("config", "build_manifest.json").read)
  end
end
