class Admin::ItemValuesController < ResourceController::Base

  belongs_to [:research, :item]

end
