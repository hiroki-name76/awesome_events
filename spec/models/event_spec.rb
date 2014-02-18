# -*- coding: utf-8 -*-
require 'spec_helper'

describe Event do
  it { should have_many(:tickets).dependent(:destroy) }
  it { should belong_to(:owner).class_name('User') }

  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(50) }
  end

  describe '#place' do
    it { should validate_presence_of(:place) }
    it { should ensure_length_of(:place).is_at_most(100) }
  end

  describe '#content' do
    it { should validate_presence_of(:content) }
    it { should ensure_length_of(:content).is_at_most(2000) }
  end

  describe '#start_time' do
    it { should validate_presence_of(:start_time) }
  end

  describe '#end_time' do
    it { should validate_presence_of(:end_time) }
  end

  describe '#start_time_should_be_before_end_time' do
    let(:now) { Time.zone.now }

    context '#start_time もしくは #end_time が nil なとき' do
      it '#errors[:start_time] が空であること' do
        event = Event.new(start_time: now, end_time: nil)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_empty

        event = Event.new(start_time: nil, end_time: now)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_empty

        event = Event.new(start_time: nil, end_time: nil)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_empty
      end
    end

    context '#start_time と #end_time が同時刻なとき' do
      it '#errors[:start_time] が空でないこと' do
        event = Event.new(start_time: now, end_time: now)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_present
      end
    end

    context '#start_time と比べて #end_time が1分後なとき' do
      it '#errors[:start_time] が空であること' do
        event = Event.new(start_time: now, end_time: now + 1.minute)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_blank
      end
    end

    context '#start_time と比べて #end_time が1分前なとき' do
      it '#errors[:start_time] が空でないこと' do
        event = Event.new(start_time: now, end_time: now - 1.minute)
        event.send(:start_time_should_be_before_end_time)
        expect(event.errors[:start_time]).to be_present
      end
    end
  end

  describe '#event_image_should_have_valid_mime_type' do
    valid_content_types = %w(image/jpeg image/png image/gif)

    valid_content_types.each do |valid_content_type|
      context "#event_image.file.content_type が '#{valid_content_type}' を返すとき" do
        let!(:event) do
          event = Event.new
          allow(event).to receive(:event_image) { double('event_image', file: double('file', content_type: valid_content_type)) }
          event
        end

        it '#errors[:event_image] が空であること' do
          event.send(:event_image_should_have_valid_mime_type)
          expect(event.errors[:event_image]).to be_blank
        end
      end
    end

    invalid_content_types = %w(text/plain text/css video/mpeg)
    invalid_content_types.each do |invalid_content_type|
      context "#event_image.file.content_type が '#{invalid_content_type}' を返すとき" do
        let!(:event) do
          event = Event.new
          allow(event).to receive(:event_image) { double('event_image', file: double('file', content_type: invalid_content_type)) }
          event
        end

        it '#errors[:event_image] が空でないこと' do
          event.send(:event_image_should_have_valid_mime_type)
          expect(event.errors[:event_image]).to be_present
        end
      end
    end
  end

  describe '#created_by?' do
    let(:event) { create(:event) }
    subject { event.created_by?(user) }

    context '引数が nil なとき' do
      let(:user) { nil }
      it { should be_falsey }
    end

    context '#owner_id と 引数の#id が同じとき' do
      let(:user) { double('user', id: event.owner_id) }
      it { should be_truthy }
    end
  end
end
