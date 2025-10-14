# Monaco RGPD Compliance Areas based on Loi n° 1.565

compliance_areas_data = [
  {
    name: "Licéité du traitement",
    code: "lawfulness",
    description: "Bases juridiques et licéité des traitements de données personnelles"
  },
  {
    name: "Information des personnes",
    code: "transparency",
    description: "Transparence et information des personnes concernées"
  },
  {
    name: "Droits des personnes",
    code: "rights",
    description: "Respect des droits d'accès, rectification, effacement, opposition, etc."
  },
  {
    name: "Sécurité des données",
    code: "security",
    description: "Mesures techniques et organisationnelles de sécurité"
  },
  {
    name: "Transferts de données",
    code: "transfers",
    description: "Transferts de données vers des pays tiers"
  }
]

compliance_areas_data.each do |area_data|
  ComplianceArea.find_or_create_by!(code: area_data[:code]) do |area|
    area.name = area_data[:name]
    area.description = area_data[:description]
  end
end

puts "✓ Created #{ComplianceArea.count} compliance areas"
