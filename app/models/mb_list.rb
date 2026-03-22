# MbList model - MycoBank taxonomic data
#
# Data source: MycoBank MBList database (https://www.mycobank.org)
# License: Creative Commons CC BY-NC-ND
#   - BY (Attribution): Credit must be given to MycoBank
#   - NC (Non-Commercial): Non-commercial use only
#   - ND (No Derivatives): Data used in unadapted form only
#
# Attribution: MBList taxonomic data provided by MycoBank (www.mycobank.org)
class MbList < ApplicationRecord
  validates :taxon_name, presence: true
end
