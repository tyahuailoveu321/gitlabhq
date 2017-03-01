require 'rails_helper'

describe 'Issue Boards', :feature, :js do
  include WaitForVueResource
  include DragTo

  let(:project) { create(:empty_project, :public) }
  let(:board) { create(:board, project: project) }
  let(:user) { create(:user) }
  let(:label) { create(:label, project: project) }
  let!(:list1) { create(:list, board: board, label: label, position: 0) }
  let!(:issue1) { create(:labeled_issue, project: project, title: 'testing 1', labels: [label], relative_position: 3) }
  let!(:issue2) { create(:labeled_issue, project: project, title: 'testing 2', labels: [label], relative_position: 2) }
  let!(:issue3) { create(:labeled_issue, project: project, title: 'testing 3', labels: [label], relative_position: 1) }

  before do
    project.team << [user, :master]

    login_as(user)
  end

  context 'ordering in list' do
    before do
      visit namespace_project_board_path(project.namespace, project, board)
      wait_for_vue_resource

      expect(page).to have_selector('.board', count: 2)
    end

    it 'moves from middle to top' do
      drag(from_index: 1, to_index: 0)

      wait_for_vue_resource

      expect(first('.card')).to have_content(issue2.title)
    end

    it 'moves from middle to bottom' do
      drag(from_index: 1, to_index: 2)

      wait_for_vue_resource

      expect(all('.card').last).to have_content(issue2.title)
    end

    it 'moves from top to bottom' do
      drag(from_index: 0, to_index: 2)

      wait_for_vue_resource

      expect(all('.card').last).to have_content(issue3.title)
    end

    it 'moves from bottom to top' do
      drag(from_index: 2, to_index: 0)

      wait_for_vue_resource

      expect(first('.card')).to have_content(issue1.title)
    end

    it 'moves from top to middle' do
      drag(from_index: 0, to_index: 1)

      wait_for_vue_resource

      expect(first('.card')).to have_content(issue2.title)
    end

    it 'moves from bottom to middle' do
      drag(from_index: 2, to_index: 1)

      wait_for_vue_resource

      expect(all('.card').last).to have_content(issue2.title)
    end
  end

  context 'ordering when changing list' do
    let(:label2) { create(:label, project: project) }
    let!(:list2) { create(:list, board: board, label: label2, position: 1) }
    let!(:issue4) { create(:labeled_issue, project: project, title: 'testing 1', labels: [label2], relative_position: 3.0) }
    let!(:issue5) { create(:labeled_issue, project: project, title: 'testing 2', labels: [label2], relative_position: 2.0) }
    let!(:issue6) { create(:labeled_issue, project: project, title: 'testing 3', labels: [label2], relative_position: 1.0) }

    before do
      visit namespace_project_board_path(project.namespace, project, board)
      wait_for_vue_resource

      expect(page).to have_selector('.board', count: 3)
    end

    it 'moves to top of another list' do
      drag(list_from_index: 0, list_to_index: 1)

      wait_for_vue_resource

      expect(first('.board')).to have_selector('.card', count: 2)
      expect(all('.board')[1]).to have_selector('.card', count: 4)

      page.within(all('.board')[1]) do
        expect(first('.card')).to have_content(issue3.title)
      end
    end

    it 'moves to bottom of another list' do
      drag(list_from_index: 0, list_to_index: 1, to_index: 2)

      wait_for_vue_resource

      expect(first('.board')).to have_selector('.card', count: 2)
      expect(all('.board')[1]).to have_selector('.card', count: 4)

      page.within(all('.board')[1]) do
        expect(all('.card').last).to have_content(issue3.title)
      end
    end

    it 'moves to index of another list' do
      drag(list_from_index: 0, list_to_index: 1, to_index: 1)

      wait_for_vue_resource

      expect(first('.board')).to have_selector('.card', count: 2)
      expect(all('.board')[1]).to have_selector('.card', count: 4)

      page.within(all('.board')[1]) do
        expect(all('.card')[1]).to have_content(issue3.title)
      end
    end
  end

  def drag(selector: '.board-list', list_from_index: 0, from_index: 0, to_index: 0, list_to_index: 0)
    drag_to(selector: selector,
            scrollable: '#board-app',
            list_from_index: list_from_index,
            from_index: from_index,
            to_index: to_index,
            list_to_index: list_to_index)
  end
end
