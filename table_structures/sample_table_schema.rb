class SampleTableSchema
  include TableStructure::Schema

  TableContext = Struct.new(:questions, :friend_num, :pet_num, keyword_init: true)

  context_builder :table do |context|
    TableContext.new(**context)
  end

  columns UserTableSchema

  columns ->(table) {
    table.friend_num.times.map do |n|
      UserTableSchema.new(
        context: table,
        name_prefix: "Friend #{n + 1} ",
        key_prefix: "friend_#{n + 1}_"
      ) do
        context_builder :row do |context|
          context.friend_users[n]
        end
      end
    end
  }

  columns ->(table) {
    if table.pet_num.positive?
      {
        name: table.pet_num.times.map { |n| "Pet #{n + 1}" },
        key: table.pet_num.times.map { |n| :"pet#{n + 1}" },
        value: ->(row, *) { row.pets.map { |pet| pet.creature.emoji } },
      }
    end
  }

  columns ->(table) {
    table.questions.map.with_index do |question, i|
      n = i + 1
      {
        name: "Q#{n} (#{question.text})",
        key: :"q#{n}",
        value: ->(row, *) {
          row
            .answers
            .find { |answer| answer.question_id == question.id }
            .text
        }
      }
    end
  }

  column_converter :to_s do |val, *|
    val.to_s
  end
end
