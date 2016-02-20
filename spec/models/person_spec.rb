require 'rails_helper'

describe Person do
  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :dob }
    it { is_expected.to validate_presence_of :gender }
    it { is_expected.to enumerize(:gender).in(:male, :female) }
  end

  context 'associations' do
    it { is_expected.to have_one :fathership }
    it { is_expected.to have_one :mothership }
    it { is_expected.to have_one :husbandship }
    it { is_expected.to have_one :wifeship }

    it { is_expected.to have_one :father }
    it { is_expected.to have_one :mother }
    it { is_expected.to have_one :husband }
    it { is_expected.to have_one :wife }

    it { is_expected.to have_many :parentships }
    it { is_expected.to have_many :childrenships }
    it { is_expected.to have_many :friendships }
    it { is_expected.to have_many :friends_of_friendships }
    it { is_expected.to have_many :friends_of_friends }

    it { is_expected.to have_many :parents }
    it { is_expected.to have_many :children }
    it { is_expected.to have_many :sons }
    it { is_expected.to have_many :daughters }
    it { is_expected.to have_many :brothers }
    it { is_expected.to have_many :friends }
  end

  describe 'relationships' do
    let!(:alex) { create(:person, first_name: 'Alex') }

    describe '#father' do
      let!(:mason)      { create(:male, first_name: 'Mason') }
      let!(:fathership) { create(:fathership, person: alex, member: mason) }

      it 'returns father' do
        expect(alex.father).to match mason.becomes(Father)
      end
    end

    describe '#mother' do
      let!(:ava)        { create(:female,   first_name: 'Ava') }
      let!(:mothership) { create(:mothership, person: alex, member: ava) }

      it 'returns mother' do
        expect(alex.mother).to match ava.becomes(Mother)
      end
    end

    describe '#children, #sons, #brothers' do
      let!(:peter)  { create(:male,   first_name: 'Peter') }
      let!(:anna)   { create(:female, first_name: 'Anna') }

      before do
        create(:fathership, person: peter, member: alex)
        create(:fathership, person: anna,  member: alex)
      end

      it 'returns children' do
        expect(alex.children).to include anna.becomes(Child)
        expect(alex.children.size).to eq 2
      end

      it 'returns sons' do
        expect(alex.sons).to include peter.becomes(Son)
        expect(alex.sons.size).to eq 1
      end

      it 'returns daughters' do
        expect(alex.daughters).to include anna.becomes(Daughter)
        expect(alex.daughters.size).to eq 1
      end

      it 'returns brothers' do
        expect(anna.brothers).to include peter.becomes(Brother)
        expect(anna.brothers.size).to eq 1
        expect(peter.brothers.size).to eq 0
      end
    end
  end

  describe '#father_of?' do
    let!(:alex)   { create(:person, first_name: 'Alex') }
    let!(:mason)  { create(:male,   first_name: 'Mason') }
    let!(:fathership) { create(:fathership, person: mason, member: alex) }

    it 'true' do
      expect(alex.father_of?(mason)).to be true
    end

    it 'false' do
      expect(mason.father_of?(alex)).to be false
    end
  end

  describe '#older_than' do
    let!(:alex)   { create(:person, first_name: 'Alex', dob: 18.years.ago) }
    let!(:mason)  { create(:person, first_name: 'Mason', dob: 40.years.ago) }

    it 'returns number of years' do
      expect(mason.older_than(alex)).to eq 22
    end
  end

  describe '#set_name' do
    let!(:person) { create(:person, first_name: "James", last_name: "La") }

    it 'sets full name before saving' do
      expect(person.name).to eq 'James La'
    end
  end

  describe '#ensure_valid_age' do
    let(:person) { build(:person) }

    context 'valid' do
      [1.year.ago, 18.years.ago].each do |dob|
        it "#{dob}" do
          person.dob = dob
          expect(person).to be_valid
        end
      end
    end

    context 'invalid' do
      [1.year.from_now, 18.years.from_now].each do |dob|
        it "#{dob}" do
          person.dob = dob
          expect(person).to_not be_valid
        end
      end
    end
  end

  describe '#husband , #wife' do
    let!(:john)  { create(:male,     first_name: 'John') }
    let!(:lily)  { create(:female,   first_name: 'Lily') }
    let!(:wifeship)     { create(:wifeship,   person: john,  member: lily) }
    let!(:husbandship)  { create(:husbandship,   person: lily,  member: john) }

    it "john'wife is lily" do
      expect(john.wife).to eq(lily.becomes(Wife))
    end

    it "lily'husband is lily" do
      expect(lily.husband).to eq(john.becomes(Husband))
    end
  end

  describe '#mother_in_law' do
    let!(:john)  { create(:male,     first_name: 'John') }
    let!(:lily)  { create(:female,   first_name: 'Lily') }
    let!(:mina)  { create(:female,   first_name: 'Mina') }
    let!(:sofia) { create(:female,   first_name: 'Sofia') }
    let!(:fathership) { create(:fathership, person: sofia, member: john) }
    let!(:wifeship)   { create(:wifeship,   person: john,  member: lily) }

    context "sofia's mother is nil" do
      it "returns nil" do
        expect(sofia.mother_in_law).to be nil
      end
    end

    context "sofia's mother is mina" do
      let!(:mothership)   { create(:mothership, person: sofia, member: mina) }
      it "returns lily" do
        expect(sofia.mother_in_law).to eq(lily.becomes(Wife))
      end
    end
  end
end
