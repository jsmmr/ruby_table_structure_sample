class UserSchema
  include TableStructure::Schema

  TableContext = Struct.new(:questions, keyword_init: true)

  context_builder :table, ->(context) { TableContext.new(**context) }

  column  name: 'ID',
          value: ->(row, *) { row.id }

  column  name: 'Name',
          value: ->(row, *) { row.name }

  columns name: (1..5).map { |num| "Pet #{num}" },
          value: ->(row, *) { row.pets.map { |pet| pet.creature.emoji } }

  columns ->(table) {
    table.questions.map.with_index do |question, i|
      {
        name: "Q#{i + 1} (#{question.text})",
        value: ->(row, *) {
          row
            .answers
            .find { |answer| answer.question_id == question.id }
            .text
        }
      }
    end
  }

  column_converter :to_s, ->(val, *) { val.to_s }
end
