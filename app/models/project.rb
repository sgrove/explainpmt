##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


# A Project is the hub which connects User, Milestone, Iteration, and Story
# objects (and any other information in the system). With the exception of User
# objects, everything else _must_ be associated with a project; and when a
# project is deleted, everything associated with the project (except the User
# accounts) should be deleted as well.
#
# Project has the following associations:
#   has_many :iterations, :order => 'start_date ASC', :dependent => :destroy
#   has_many :milestones, :order => 'date ASC', :dependent => :destroy
#   has_many :stories, :dependent => :destroy
#   has_many :backlog, :class_name => 'Story',
#            :conditions => "iteration_id IS NULL"
#   has_and_belongs_to_many :users, :order => 'last_name ASC, first_name ASC'
#
# And the following data validations:
#   validates_presence_of :name
#   validates_uniqueness_of :name
#   validates_length_of :name, :maximum => 100
#
class Project < ActiveRecord::Base
  has_many :sub_projects, :order => 'name', :dependent => :destroy
  
  has_many :iterations, :order => 'start_date ASC', :dependent => :destroy do
    def past
      self.reverse.select { |i| i.past? }
    end

    def future
      self.select { |i| i.future? }
    end

    def previous
      past.first
    end

    def next
      future.first
    end

    def current
      self.detect { |i| i.current? }
    end
  end
  
  has_many :milestones, :order => 'date ASC', :dependent => :destroy do
    def future
      self.select { |m| m.future? }
    end
  
    def recent
      self.reverse.select { |m| m.recent? }
    end
  
    def past
      self.reverse.select { |m| m.past? }
    end
  end

  has_many :stories, :dependent => :destroy do
    def backlog
      self.select { |s| s.iteration.nil? }
    end
  end
  
  has_and_belongs_to_many :users, :order => 'last_name ASC, first_name ASC'
  has_many :acceptancetests, :dependent => :destroy
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 100
end

