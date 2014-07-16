/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of GNOMECAT
 *
 * Copyright (C) 2013 - Marcos Chavarría Teijeiro
 *
 * GNOMECAT is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOMECAT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOMECAT. If not, see <http://www.gnu.org/licenses/>.
 */


using Gee;

namespace GNOMECAT.Iterators
{
    public abstract class IteratorFilter<E> : Object
    {
        /**
         * Method that checks if an element is valid.
         */
        public abstract bool check (E element);
    }


    public class TranslatedFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.TRANSLATED;
        }
    }


    public class UntranslatedFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.UNTRANSLATED;
        }
    }


    public class FuzzyFilter : IteratorFilter<Message>
    {
        public override bool check (Message element)
        {
            return element.state == MessageState.FUZZY;
        }
    }


    public class ORFilter<R> : IteratorFilter<R>
    {

        public ArrayList<IteratorFilter<R>> filters {get; private set;}

        public ORFilter (ArrayList<IteratorFilter<R>> filters)
        {
            this.filters = filters;
        }

        public override bool check (R m)
        {
            foreach (IteratorFilter<R> mf in filters)
                if (mf.check (m))
                    return true;
            return false;
        }
    }


    public class OriginalFilter : IteratorFilter<MessageFragment>
    {
        public override bool check (MessageFragment mm)
        {
            return mm.is_original;
        }
    }


    public class TranslationFilter : IteratorFilter<MessageFragment>
    {
        public override bool check (MessageFragment mm)
        {
            return ! mm.is_original;
        }
    }


    public class TransparentFilter<Element> : IteratorFilter<Element>
    {
        public override bool check (Element ele)
        {
            return true;
        }
    }
}