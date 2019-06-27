# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CodebreakerRack do
  OVERRIDABLE_FILENAME = 'spec/fixtures/scores.yml'

  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:non_existent_path) { '/fdsfdsf' }
  let(:urls) { Router::URLS }

  context 'when path requests' do
    before do
      stub_const('Database::PATH', OVERRIDABLE_FILENAME)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    context 'when #index' do
      it { expect(get(urls[:root])).to be_ok }

      it do
        get urls[:root]

        expect(last_response.body).to include(I18n.t(:player_name_input))
        expect(last_response.body).to include(I18n.t(:difficulty_input))
        expect(last_response.body).to include(I18n.t(:start_game_button))
      end
    end

    context 'when #rules' do
      let(:rules) do
        [
          I18n.t('rules_rows.each_guess'),
          I18n.t('rules_rows.numbers_may'),
          I18n.t('rules_rows.win_only'),
          I18n.t('rules_rows.lose_if'),
          I18n.t('rules_rows.plus_sign'),
          I18n.t('rules_rows.minus_sign')
        ]
      end

      it { expect(get(urls[:rules])).to be_ok }

      it do
        get urls[:rules]

        rules.each do |rule|
          expect(last_response.body).to include(rule)
        end
      end
    end

    context 'when #statistics' do
      let(:data) do
        { difficulty: [0, :kid],
          secret: '[6, 2, 3, 5]',
          tries_total: '15',
          hints_total: '2',
          tries_used: '1',
          hints_used: '0',
          player_name: 'dasd',
          datetime: '22 Jun 2019 - 12:40:09' }
      end

      context 'when empty' do
        it { expect(get(urls[:statistics])).to be_ok }

        it do
          get urls[:statistics]

          expect(last_response.body).to include(I18n.t(:top_players_title))
          expect(last_response.body).to include(I18n.t(:empty_stats))
          expect(last_response.body).to include(I18n.t(:home_button))
        end
      end

      context 'when with data' do
        it { expect(get(urls[:statistics])).to be_ok }

        it do
          allow(Database).to receive(:load).and_return([data])

          get urls[:statistics]

          expect(last_response.body).not_to include(I18n.t(:empty_stats))
          expect(last_response.body).to include('table-responsive')
          expect(last_response.body).to include(I18n.t(:home_button))
        end
      end
    end

    context 'when #game' do
      context 'when not active' do
        let(:auth_locations) { %i[game submit_answer hint] }

        it do
          auth_locations.each do |location|
            expect(get(urls[location])).to be_redirect

            expect(last_response.header['Location']).to eq(urls[:root])
          end
        end
      end

      context 'when active' do
        let(:player_name) { 'Euler' }
        let(:difficulty) { :hacker }
        let(:valid_number) { '1234' }
        let(:tries_count) { BaseController::DIFFICULTIES[difficulty][:tries] }
        let(:free_locations) { %i[root rules statistics] }

        before do
          post urls[:game], player_name: player_name, difficulty: difficulty
        end

        it do
          free_locations.each do |location|
            expect(get(urls[location])).to be_redirect

            expect(last_response.header['Location']).to eq(urls[:game])
          end

          expect(last_response.header['Location']).to eq(urls[:game])

          2.times { get(urls[:hint]) }
          expect(get(urls[:hint])).to be_redirect
        end

        context 'when start game' do
          context 'with invalid params' do
            let(:player_name) { 'a' }

            it do
              expect(last_response).to be_redirect
              expect(last_response.header['Location']).to eq(urls[:root])
            end
          end

          context 'with valid params' do
            it { expect(last_response).to be_ok }
            it { expect(last_response.body).to include(player_name) }
            it { expect(last_response.body).to include(difficulty.to_s) }

            it 'saves game to session' do
              expect(last_request.session[:game].tries_count).to eq(tries_count)
            end

            it 'saves users name to session' do
              expect(last_request.session[:player].name).to eq(player_name)
            end
          end
        end

        context 'when submit_answer' do
          before do
            post urls[:submit_answer], number: valid_number
          end

          it { expect(last_response).to be_ok }

          it { expect(last_request.session[:game].instance_variable_get(:@matches)).to be_kind_of(String) }
        end

        context 'when hint' do
          it do
            get(urls[:hint])

            expect(last_response).to be_ok
            expect(last_request.session[:game].instance_variable_get(:@hints)).not_to be_empty
          end
        end

        context 'when #game_finished' do
          it do
            post urls[:submit_answer], number: last_request.session[:game].instance_variable_get(:@secret).join

            expect(last_response).to be_redirect
            expect(last_response.header['Location']).to eq(urls[:game_results])
          end

          context 'when secred code guessed' do
            it do
              post urls[:submit_answer], number: last_request.session[:game].instance_variable_get(:@secret).join

              expect(get(urls[:game_results])).to be_ok

              expect(last_request.session).not_to include(:game)
              expect(last_request.session).not_to include(:player)

              expect(last_response.body).to include(I18n.t(:congrats, player_name: player_name, status: :win))
            end
          end

          context 'when tries exceeded' do
            it do
              5.times { post urls[:submit_answer], number: valid_number }

              expect(get(urls[:game_results])).to be_ok

              expect(last_request.session).not_to include(:game)
              expect(last_request.session).not_to include(:player)

              expect(last_response.body).to include(I18n.t(:oops, player_name: player_name, status: :lose))
            end
          end
        end
      end
    end

    context 'when #404' do
      it do
        get(non_existent_path)

        expect(last_response).to be_not_found

        expect(last_response.body).to include(I18n.t(:page_not_found))
        expect(last_response.body).to include(I18n.t(:home_button))
      end
    end
  end
end
