module LuckyFlow::Spec
  macro setup
    Spec.around_each do |spec|
      if driver_name = (spec.example._lucky_flow_all_tags & LuckyFlow::Registry.available).first?
        LuckyFlow.driver(driver_name)
      end

      spec.run

      LuckyFlow.reset
      LuckyFlow.use_default_driver
    end

    Spec.after_suite do
      LuckyFlow.shutdown
    end
  end
end
