module SemesterHelper
  def semester_info(semester)
    return nil if not semester
    sem = {}
    sem['id'] = semester.id
    sem['active'] = semester.active
    sem['university'] = semester.university.name
    sem['name'] = semester.name
    sem['start'] = semester.start
    sem['end'] = semester.end
    sem['exams_start'] = semester.exams_start
    sem['exams_end'] = semester.exams_end
    sem
  end

  # Available semesters are:
  # [0] - Previous
  # [1] - Current one - according to dates and what selected by user
  # [2] - Next one
  def available_semesters
    # We assume that database is sorted by date
    prev_sem = Semester.where("university_id = ? AND id < ?",
                              @user.semester.university_id, @user.semester_id).order("id DESC").first;
    next_sem = Semester.where("university_id = ? AND id > ?",
                              @user.semester.university_id, @user.semester_id).order("id ASC").first;
    semesters = {}
    semesters[:prev] = semester_info(prev_sem)
    semesters[:cur] = semester_info(@user.semester)
    semesters[:next] = semester_info(next_sem)
    semesters
  end
end
